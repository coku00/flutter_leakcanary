class CodeInfo {
  int? line;
  int? column;
  String? codeLine;
  String? uri;

  CodeInfo(this.line, this.column, this.codeLine, this.uri);

  @override
  String toString() {
    return 'line :$line; column :$column; codeLine :$codeLine';
  }
}