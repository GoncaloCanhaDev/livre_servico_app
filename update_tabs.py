import re

with open('lib/screens/historico_screen.dart', 'r') as f:
    content = f.read()

# Replace class definition
content = re.sub(r'class (_[A-Za-z]+TabState) extends State<(_[A-Za-z]+Tab)> {',
                 r'class \1 extends State<\2> with AutomaticKeepAliveClientMixin {\n  @override\n  bool get wantKeepAlive => true;',
                 content)

# Add super.build(context); to build methods of these tabs
# We need to find @override\n  Widget build(BuildContext context) { and add super.build(context);
# But only inside these TabState classes. Since all of them have the same build signature and are in this file, we can just replace all `Widget build(BuildContext context) {` that are after `wantKeepAlive => true;`. 
# Actually, we can just replace all `Widget build(BuildContext context) {` in the file except the one for `HistoricoScreen`, `_emptyMsg`, etc. Wait, `HistoricoScreen` has `Widget build(BuildContext context) {`. `_HistoryDismissible` has it.
# A better way is:
content = re.sub(r'(@override\s+Widget build\(BuildContext context\) {\s+)(final|return FutureBuilder)', 
                 r'\1super.build(context);\n    \2', 
                 content)

with open('lib/screens/historico_screen.dart', 'w') as f:
    f.write(content)
