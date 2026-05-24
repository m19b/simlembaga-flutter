import re

files = [
    r'd:\PROJEK\projekrun\simflutter\manajemen_tahsin_app\lib\features\pra_tahfidz\presentation\pra_tahfidz_screen.dart',
    r'd:\PROJEK\projekrun\simflutter\manajemen_tahsin_app\lib\features\tahfidz\presentation\tahfidz_screen.dart',
    r'd:\PROJEK\projekrun\simflutter\manajemen_tahsin_app\lib\features\progress\presentation\progress_screen.dart'
]

for filepath in files:
    try:
        with open(filepath, 'r', encoding='utf-8') as f:
            content = f.read()

        if 'AppHeaderBar' not in content:
            if 'app_header_bar.dart' not in content:
                content = content.replace("import 'package:flutter/material.dart';", "import 'package:flutter/material.dart';\nimport 'package:manajemen_tahsin_app/core/widgets/app_header_bar.dart';")
            
            # Find the appBar: PreferredSize(...) block
            start_str = 'appBar: PreferredSize('
            start_idx = content.find(start_str)
            if start_idx == -1:
                print(f"Pattern not found in {filepath}")
                continue
                
            # Parse brackets to find end
            open_brackets = 0
            end_idx = -1
            for i in range(start_idx + len('appBar: '), len(content)):
                if content[i] == '(':
                    open_brackets += 1
                elif content[i] == ')':
                    open_brackets -= 1
                    if open_brackets == 0:
                        end_idx = i
                        break
            
            if end_idx != -1:
                appbar_block = content[start_idx:end_idx+1]
                
                # Extract title and actions
                title_match = re.search(r'title:\s*(.*?)(?=\n\s*actions:)', appbar_block, re.DOTALL)
                actions_match = re.search(r'actions:\s*(\[.*?\]),?\s*\n\s*\),', appbar_block, re.DOTALL)
                
                title = title_match.group(1).strip() if title_match else "Text('Menu')"
                # Ensure trailing comma in title is removed
                if title.endswith(','): title = title[:-1]
                
                actions = actions_match.group(1).strip() if actions_match else "[]"
                
                new_appbar = f'''appBar: AppHeaderBar(
        customTitle: {title},
        actions: {actions},
      )'''
                
                content = content[:start_idx] + new_appbar + content[end_idx+1:]
                
                with open(filepath, 'w', encoding='utf-8') as f:
                    f.write(content)
                print(f"Successfully updated {filepath}")
            else:
                print(f"End of PreferredSize not found in {filepath}")
        else:
            print(f"Already has AppHeaderBar: {filepath}")
    except Exception as e:
        print(f"Error processing {filepath}: {e}")
