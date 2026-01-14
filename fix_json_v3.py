import json
import re

# Read the original file
with open('word_levels.json', 'r', encoding='utf-8') as f:
    content = f.read()

# Create a completely new approach
# We'll parse line by line and fix each one manually

lines = content.split('\n')
fixed_lines = []
brace_count = 0
array_depth = 0

for i, line in enumerate(lines):
    original = line
    
    # Track brace and array depth
    brace_count += line.count('{') - line.count('}')
    array_depth += line.count('[') - line.count(']')
    
    # Fix 1: Add quotes to keys (word before colon, but not if already quoted)
    # This regex finds unquoted words followed by colon
    line = re.sub(r'(\s*)(\w+)(\s*:)', r'\1"\2"\3', line)
    
    # Fix 2: Add quotes to values
    # We need to be careful here - we want to quote string values but not special values
    
    # For lines inside objects (have unquoted values after colons)
    if brace_count > 0 or array_depth > 0:
        # Split by comma to process each field
        parts = line.split(',')
        fixed_parts = []
        
        for part in parts:
            part = part.strip()
            
            # Check if this part contains a colon (key-value pair)
            if ':' in part:
                key_value = part.split(':', 1)
                if len(key_value) == 2:
                    key = key_value[0].strip()
                    value = key_value[1].strip()
                    
                    # Add quotes to value if it's not already quoted and not special
                    if value and not value.startswith('"') and not value.startswith('['):
                        # Check if it's not a number or boolean
                        if not value.lower() in ['true', 'false', 'null']:
                            if value.replace('.', '').replace('-', '').isdigit():
                                # It's a number
                                fixed_parts.append(f'{key}: {value}')
                            else:
                                # It's a string, add quotes
                                fixed_parts.append(f'{key}: "{value}"')
                        else:
                            fixed_parts.append(f'{key}: {value}')
                    else:
                        fixed_parts.append(f'{key}: {value}')
                else:
                    fixed_parts.append(part)
            else:
                fixed_parts.append(part)
        
        line = ','.join(fixed_parts)
    
    fixed_lines.append(line)
    
    # Debug output every 100 lines
    if i < 5:
        print(f"Line {i+1}: {line[:80]}...")

content = '\n'.join(fixed_lines)

# Remove trailing commas
content = re.sub(r',\s*([}\]])', r'\1', content)

# Save intermediate
with open('word_levels_step1.json', 'w', encoding='utf-8') as f:
    f.write(content)

print("\nStep 1 complete, trying to parse...")

try:
    data = json.loads(content)
    with open('word_levels_fixed.json', 'w', encoding='utf-8') as f:
        json.dump(data, f, ensure_ascii=False, indent=2)
    print("Success! Fixed file saved.")
except json.JSONDecodeError as e:
    print(f"Error: {e}")
    # Show where the error is
    print(f"Error at line {content[:e.pos].count(chr(10)) + 1}")
    
    # Show context around error
    lines = content.split('\n')
    error_line = content[:e.pos].count('\n')
    print(f"Error context (lines {max(0, error_line-2)} to {min(len(lines), error_line+3)}):")
    for i in range(max(0, error_line-2), min(len(lines), error_line+3)):
        marker = " >>> " if i == error_line else "     "
        print(f"{marker}{i+1}: {lines[i]}")
