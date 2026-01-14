import json
import re

# Read the original file
with open('word_levels.json', 'r', encoding='utf-8') as f:
    content = f.read()

# Fix the JSON by adding quotes around keys and string values
# First, add quotes around keys (words before colons)
content = re.sub(r'(\w+):\s*(\[|{)', r'"\1": \2', content)

# Add quotes around string values
# This is more complex because we need to handle different cases
lines = content.split('\n')
fixed_lines = []
for line in lines:
    # Add quotes to keys
    line = re.sub(r'^(\s*)(\w+):', r'\1"\2":', line)
    
    # Add quotes to values (after colon, before comma or end of line)
    # Handle values like: value,
    line = re.sub(r':\s*([^,{}"\[\]]+),?', r': "\1",', line)
    
    # Fix the array brackets
    line = line.replace('[', '[')
    line = line.replace(']', ']')
    
    fixed_lines.append(line)

fixed_content = '\n'.join(fixed_lines)

# Now we need to properly quote all string values
# Split by objects
objects = fixed_content.split('},')
fixed_objects = []
for i, obj in enumerate(objects):
    if i == len(objects) - 1:
        # Last object might not have trailing comma
        if not obj.strip().endswith('}') and not obj.strip().endswith('},'):
            obj = obj + '}'
    
    # Add quotes to all keys in this object
    obj = re.sub(r'(\w+):', r'"\1":', obj)
    
    # Add quotes to string values
    # This pattern matches values that are not already quoted
    obj = re.sub(r':\s*([^\s,{}"\[\]]+)\s*([,}])', r': "\1"\2', obj)
    
    fixed_objects.append(obj)

fixed_content = '},'.join(fixed_objects)

# Try to parse and pretty print
try:
    data = json.loads(fixed_content)
    with open('word_levels_fixed.json', 'w', encoding='utf-8') as f:
        json.dump(data, f, ensure_ascii=False, indent=2)
    print("Successfully fixed and saved as word_levels_fixed.json")
except json.JSONDecodeError as e:
    print(f"Error: {e}")
    # If there's an error, save the intermediate version
    with open('word_levels_intermediate.json', 'w', encoding='utf-8') as f:
        f.write(fixed_content)
    print("Saved intermediate version as word_levels_intermediate.json")
