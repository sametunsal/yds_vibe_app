import json
import os

def count_todos():
    file_path = r'd:\proje\yds_vibe_app\assets\mvl\verbs.json'
    if not os.path.exists(file_path):
        print("File not found.")
        return

    with open(file_path, 'r', encoding='utf-8') as f:
        data = json.load(f)

    todos = []
    for item in data:
        if "TODO: Fill with AI" in str(item.get('meanings', [])) or \
           "TODO: Fill with AI" in str(item.get('example', {})) or \
           "TODO: Fill with AI" in str(item.get('cloze', {})):
            todos.append(item['lemma'])

    print(f"Total items: {len(data)}")
    print(f"Items with TODOs: {len(todos)}")
    print("Lemmas with TODOs (first 50):")
    print(todos[:50])

if __name__ == "__main__":
    count_todos()
