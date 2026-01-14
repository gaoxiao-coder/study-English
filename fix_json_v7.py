import json
import re

# Read the original file
with open('word_levels.json', 'r', encoding='utf-8') as f:
    content = f.read()

lines = content.split('\n')

# Build the data structure
data = {
    "初中词汇": []
}

current_entry = None
entries = []

for i, line in enumerate(lines):
    line = line.strip()
    
    # Skip empty lines and structural lines
    if not line or line == '{' or line == '}' or line == '[' or line == ']':
        continue
    
    # Check for new object
    if line == '{' or line.startswith('{'):
        current_entry = {}
    
    # Check for end of object
    elif line == '}' or line.endswith('}'):
        if current_entry:
            entries.append(current_entry)
            current_entry = None
    
    # Parse key-value pairs
    elif ':' in line:
        # Find the colon, but be careful with colons in values
        parts = line.split(':', 1)
        if len(parts) == 2:
            key = parts[0].strip()
            value = parts[1].strip()
            
            # Remove trailing comma if present
            if value.endswith(','):
                value = value[:-1].strip()
            
            # Remove trailing brace if present
            if value.endswith('}'):
                value = value[:-1].strip()
            
            # Add to current entry
            if current_entry is not None:
                current_entry[key] = value

# Update data
data["初中词汇"] = entries

# Try to save as JSON
try:
    with open('word_levels_fixed.json', 'w', encoding='utf-8') as f:
        json.dump(data, f, ensure_ascii=False, indent=2)
    print("Success! Fixed file saved as word_levels_fixed.json")
    print(f"Total words in 初中词汇: {len(data.get('初中词汇', []))}")
except Exception as e:
    print(f"Error saving: {e}")
