with open('lib/screens/historico_screen.dart', 'r') as f:
    content = f.read()

# Remove super.build(context); from HistoricoScreen
# Look for:
#   Widget build(BuildContext context) {
#     super.build(context);
#     final tabs = _tabNames.map((n) => Tab(text: n)).toList();
content = content.replace("  Widget build(BuildContext context) {\n    super.build(context);\n    final tabs =", "  Widget build(BuildContext context) {\n    final tabs =")

# Wait, the script replaced it as:
#   Widget build(BuildContext context) {
#     super.build(context);
#     final tabs = ...

with open('lib/screens/historico_screen.dart', 'w') as f:
    f.write(content)
