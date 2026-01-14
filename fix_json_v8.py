import json

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
    line_stripped = line.strip()
    
    # Skip empty lines
    if not line_stripped:
        continue
    
    # Check for new object
    if line_stripped == '{' or line.startswith('{'):
        current_entry = {}
        continue
    
    # Check for end of object
    elif line_stripped == '}' or line_stripped.endswith('},') or line_stripped.endswith('}'):
        if current_entry:
            # Clean up the entry - remove trailing comma/brace from values
            cleaned_entry = {}
            for key, value in current_entry.items():
                value = value.strip()
                if value.endswith(','):
                    value = value[:-1]
                if value.endswith('}'):
                    value = value[:-1]
                cleaned_entry[key] = value
            
            entries.append(cleaned_entry)
            current_entry = None
        continue
    
    # Parse key-value pairs
    if ':' in line and current_entry is not None:
        parts = line.split(':', 1)
        if len(parts) == 2:
            key = parts[0].strip()
            value = parts[1].strip()
            
            # Add to current entry
            current_entry[key] = value

# Update data
data["初中词汇"] = entries

# Save as JSON
with open('word_levels_fixed.json', 'w', encoding='utf-8') as f:
    json.dump(data, f, ensure_ascii=False, indent=2)

print("Success! Fixed file saved as word_levels_fixed.json")
print(f"Total words in 初中词汇: {len(data.get('初中词汇', []))}")

# Show first few entries
if data["初中词汇"]:
    print("\nFirst 3 entries:")
    for i, entry in enumerate(data["初中词汇"][:3]):
        print(f"{i+1}. {entry}")
