class Lang0
macro
    NOTNL       .
    SPACE       [\ \t\n]
    COMMENT     \/\/.*
    TYPE        int
    LIT         if|else|while|return|const|[;,(){}=]
    IDCHAR      [a-zA-Z_]
    DIGIT       [0-9]
    OPERATOR    [<>=]=|[%!.|&^<>]+
rule
    {SPACE}+        { }
    {COMMENT}       { }
    {OPERATOR}      { [:OPERATOR, text] }
    {LIT}           { [text, text] }
    {TYPE}          { [:TYPE, text] }
    {IDCHAR}+       { [:NAME, text] }
    {KEYWORD}       { [:KEYWORD, text] }
    {DIGIT}+        { [:NUM, text.to_i] }
    .               { [text, text] }
end
