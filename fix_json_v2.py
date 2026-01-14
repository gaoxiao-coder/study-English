import json
import re

# Read the original file
with open('word_levels.json', 'r', encoding='utf-8') as f:
    content = f.read()

# Step 1: Fix the root object structure
# The file starts with "  初中词汇: ["
# We need to change it to "  "初中词汇": ["
content = re.sub(r'^(\s*)(\w+):\s*(\[)', r'\1"\2": \3', content)

# Step 2: Fix all object keys within the array
# Change "word:" to "word": etc. but avoid affecting the root key
lines = content.split('\n')
fixed_lines = []
in_array = False

for line in lines:
    original_line = line
    
    # Track if we're inside the array
    if '[' in line and ']' not in line:
        in_array = True
    elif ']' in line:
        in_array = False
    
    if in_array:
        # Add quotes to keys within the array objects
        line = re.sub(r'(\w+):(\s*)', r'"\1":\2', line)
    
    fixed_lines.append(line)

content = '\n'.join(fixed_lines)

# Step 3: Fix string values (values that don't have quotes)
# Match patterns like: "key": value, or "key": value }
# But avoid matching already quoted values, numbers, booleans
def fix_value(match):
    prefix = match.group(1)  # Everything before the value
    value = match.group(2)   # The value itself
    suffix = match.group(3)  # Everything after the value (comma, closing brace, etc.)
    
    # If value already has quotes, leave it alone
    if value.startswith('"') and value.endswith('"'):
        return match.group(0)
    
    # If value looks like a number or boolean, leave it alone
    if value.lower() in ['true', 'false', 'null'] or value.replace('.', '').replace('-', '').isdigit():
        return match.group(0)
    
    # Otherwise, add quotes
    return prefix + '"' + value + '"' + suffix

# Apply to lines that are inside the array
lines = content.split('\n')
fixed_lines = []
in_array = False

for line in lines:
    if '[' in line and ']' not in line:
        in_array = True
    elif ']' in line:
        in_array = False
    
    if in_array and '{' in line:
        # Fix values in object lines
        # Pattern: anything before value, then value (no quotes), then anything after
        line = re.sub(r'("\w+":\s*)([^,"{}\[\]]+)(\s*[,}])', fix_value, line)
    
    fixed_lines.append(line)

content = '\n'.join(fixed_lines)

# Step 4: Remove trailing commas before closing braces
content = re.sub(r',\s*}', '}', content)
content = re.sub(r',\s*\]', ']', content)

# Step 5: Add proper closing if missing
if not content.strip().endswith(']'):
    content = content.strip() + '\n  ]\n}'
if not content.strip().endswith('}'):
    content = content.strip() + '\n}'

# Try to parse and pretty print
try:
    data = json.loads(content)
    with open('word_levels_fixed.json', 'w', encoding='utf-8') as f:
        json.dump(data, f, ensure_ascii=False, indent=2)
    print("Successfully fixed and saved as word_levels_fixed.json")
    print(f"Total words: {len(data.get('初中词汇', []))}")
except json.JSONDecodeError as e:
    print(f"Error: {e}")
    # Save intermediate version for debugging
    with open('word_levels_debug.json', 'w', encoding='utf-8') as f:
        f.write(content)
    print("Saved debug version as word_levels_debug.json")
