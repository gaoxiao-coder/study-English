import json
import re

# Read the original file
with open('word_levels.json', 'r', encoding='utf-8') as f:
    content = f.read()

lines = content.split('\n')
fixed_lines = []
brace_count = 0
array_depth = 0

for i, line in enumerate(lines):
    brace_count += line.count('{') - line.count('}')
    array_depth += line.count('[') - line.count(']')
    
    # Fix 1: Add quotes to keys
    line = re.sub(r'(\s*)(\w+)(\s*:)', r'\1"\2"\3', line)
    
    # Fix 2: Fix values
    if brace_count > 0 or array_depth > 0:
        parts = line.split(',')
        fixed_parts = []
        
        for part in parts:
            part = part.strip()
            
            if ':' in part:
                key_value = part.split(':', 1)
                if len(key_value) == 2:
                    key = key_value[0].strip()
                    value = key_value[1].strip()
                    
                    if value and not value.startswith('"') and not value.startswith('['):
                        if not value.lower() in ['true', 'false', 'null']:
                            if value.replace('.', '').replace('-', '').isdigit():
                                fixed_parts.append(f'{key}: {value}')
                            else:
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

content = '\n'.join(fixed_lines)

# Remove trailing commas
content = re.sub(r',\s*([}\]])', r'\1', content)

# Save intermediate
with open('word_levels_step1.json', 'w', encoding='utf-8') as f:
    f.write(content)

print("Step 1 complete, trying to parse...")

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
    
    # Show context
    print("Context around error:")
    for i in range(max(0, error_line-2), min(len(lines), error_line+3)):
        print(f"{i+1}: {lines[i]}")
