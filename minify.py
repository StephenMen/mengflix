#!/usr/bin/env python3
"""Basic minifier for HTML, CSS, and JS. Strips comments and collapses whitespace."""
import re, os

def minify_html(text):
    text = re.sub(r'<!--.*?-->', '', text, flags=re.DOTALL)
    text = re.sub(r'>\s+<', '>\n<', text)
    text = re.sub(r'\s{2,}', ' ', text)
    text = re.sub(r'\n\s*\n', '\n', text)
    return text.strip()

def minify_css(text):
    text = re.sub(r'/\*.*?\*/', '', text, flags=re.DOTALL)
    text = re.sub(r'\s*([{}:;,])\s*', r'\1', text)
    text = re.sub(r';}', '}', text)
    text = re.sub(r'\s+', ' ', text)
    return text.strip()

def minify_js(text):
    # Remove single-line comments (safe: outside strings)
    lines = text.split('\n')
    result = []
    for line in lines:
        in_str = False
        str_char = None
        i = 0
        while i < len(line):
            c = line[i]
            if c in '"\'' and (i == 0 or line[i-1] != '\\'):
                if not in_str:
                    in_str = True; str_char = c
                elif c == str_char:
                    in_str = False
            elif c == '/' and not in_str:
                if i + 1 < len(line) and line[i+1] == '/':
                    line = line[:i]
                    break
                if i + 1 < len(line) and line[i+1] == '*':
                    end = line.find('*/', i+2)
                    if end >= 0:
                        line = line[:i] + line[end+2:]
                        i -= 1
            i += 1
        result.append(line)
    text = '\n'.join(result)
    # Remove multi-line block comments (careful not to break regex)
    result = []
    i = 0
    while i < len(text):
        if text[i] == '/' and i+1 < len(text) and text[i+1] == '*':
            end = text.find('*/', i+2)
            if end >= 0:
                i = end + 2
                continue
        result.append(text[i])
        i += 1
    text = ''.join(result)
    # Collapse runs of whitespace to single space
    text = re.sub(r'[ \t]+', ' ', text)
    # Remove spaces before/after punctuation (safe since strings preserved)
    text = re.sub(r'\s+([,;:])', r'\1', text)
    text = re.sub(r'([,;:])\s+', r'\1 ', text)
    text = re.sub(r'\s+([}\]\)])', r'\1', text)
    text = re.sub(r'([\{\(\[])\s+', r'\1', text)
    # Collapse empty lines
    text = re.sub(r'\n\s*\n', '\n', text)
    # Trim each line
    text = '\n'.join(l.strip() for l in text.split('\n'))
    return text.strip()

def process_file(path, minifier):
    with open(path, 'r', encoding='utf-8') as f:
        orig = f.read()
    size_before = len(orig)
    minified = minifier(orig)
    with open(path, 'w', encoding='utf-8') as f:
        f.write(minified)
    size_after = len(minified)
    saved = size_before - size_after
    pct = (saved / size_before * 100) if size_before else 0
    return (path, size_before, size_after, saved, pct)

if __name__ == '__main__':
    root = os.path.dirname(os.path.abspath(__file__))
    targets = [
        (os.path.join(root, 'index.html'), minify_html),
        (os.path.join(root, 'assets/css/styles.css'), minify_css),
        (os.path.join(root, 'assets/js/main.js'), minify_js),
    ]
    total_before = 0
    total_after = 0
    for path, fn in targets:
        if os.path.exists(path):
            name, before, after, saved, pct = process_file(path, fn)
            total_before += before
            total_after += after
            print(f"  {os.path.basename(name):30s} {before:>8,} B -> {after:>8,} B  ({pct:.1f}% saved)")
    total_saved = total_before - total_after
    total_pct = (total_saved / total_before * 100) if total_before else 0
    print(f"  {'TOTAL':30s} {total_before:>8,} B -> {total_after:>8,} B  ({total_pct:.1f}% saved)")
