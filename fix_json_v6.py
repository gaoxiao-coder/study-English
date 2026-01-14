import json
import re

# Read the original file
with open('word_levels.json', 'r', encoding='utf-8') as f:
    content = f.read()

lines = content.split('\n')
fixed_lines = []

# Process each line
for i, line in enumerate(lines):
    # Fix 1: Add quotes to keys (words before colon that aren't already quoted)
    line = re.sub(r'(\s*)(\w+)(\s*:)', r'\1"\2"\3', line)
    
    fixed_lines.append(line)

content = '\n'.join(fixed_lines)

# Now fix values - this is trickier
# We need to identify where values start and add quotes
# Values are between colon and comma (or end of line)

# Pattern: "key": value or "key": value, or "key": value }
# But value should not be quoted already, and not be a number/boolean

# Let's process line by line again
fixed_lines = []
for line in lines:
    # Check if this line has a key-value pattern
    # Match patterns like: "key": value or "key":value
    # But skip if already has quoted value
    
    if '":' in line:
        # Split by comma to get individual fields
        parts = line.split(',')
        fixed_parts = []
        
        for part in parts:
            part = part.strip()
            
            # Find the colon that separates key from value
            # Be careful with colons in the value itself
            colon_pos = part.find(':')
            if colon_pos > 0:
                key = part[:colon_pos].strip()
                value = part[colon_pos+1:].strip()
                
                # Check if key looks like a JSON key
                if key.startswith('"') and key.endswith('"'):
                    # Key is already quoted, now check value
                    if value and not value.startswith('"'):
                        # Value needs quotes if it's not empty, not a number, not boolean
                        if value.lower() in ['true', 'false', 'null']:
                            # Boolean or null
                            fixed_parts.append(f'{key}: {value}')
                        elif value.replace('.', '').replace('-', '').isdigit():
                            # Number
                            fixed_parts.append(f'{key}: {value}')
                        else:
                            # String - add quotes but be careful with internal quotes
                            # If value contains internal quotes, we need to escape them
                            # For now, just add quotes
                            fixed_parts.append(f'{key}: "{value}"')
                    else:
                        fixed_parts.append(f'{key}: {value}')
                else:
                    fixed_parts.append(part)
            else:
                fixed_parts.append(part)
        
        line = ','.join(fixed_parts)
    
    fixed_lines.append(line)

content = '\n'.join(fixed_lines)

# Remove trailing commas before closing braces/brackets
content = re.sub(r',\s*([}\]])', r'\1', content)

# Save intermediate
with open('word_levels_step2.json', 'w', encoding='utf-8') as f:
    f.write(content)

print("Step 2 complete, trying to parse...")

try:
    data = json.loads(content)
    with open('word_levels_fixed.json', 'w', encoding='utf-8') as f:
        json.dump(data, f, ensure_ascii=False, indent=2)
    print("Success! Fixed file saved as word_levels_fixed.json")
    print(f"Total words in 初中词汇: {len(data.get('初中词汇', []))}")
except json.JSONDecodeError as e:
    print(f"Error: {e}")
    lines = content.split('\n')
    error_line = content[:e.pos].count('\n')
    print(f"Error at line {error_line + 1}")
    
    # Show the problematic line
    if error_line < len(lines):
        print(f"Problematic line: {lines[error_line]}")
