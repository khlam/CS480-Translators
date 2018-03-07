#include <iostream>
#include <map>
#include <vector>
#include <algorithm>
using namespace std;

extern int yylex();
extern vector<string> symb;
extern vector<string> opt;
extern bool _error;

int main(int argc, char const *argv[]) {
  if (!yylex()) {
    cout << "#include <iostream>\nint main() {" << endl;
    sort( symb.begin(), symb.end() );

    // Print Variables
    for (auto i : symb){
      cout << "double " << i << ";" << endl;
    }

    // Print assignments
    string str = "";
    for(auto i : opt){
      if (i != ";"){
        str += i;
        str += " ";
      }
    }
    str = str.substr(0, str.size()-1);
    cout << "\n/* Begin program */\n\n" << str << "\n\n/* End program */\n" << endl;
    
    // Print print statements to print variables
    for (auto i : symb){
      cout <<"std::cout << \""<< i << ": \" << " << i << " << std::endl;" << endl;
    }
    cout << "}" << endl;
    return 0;
  } else {
    return 1;
  }
}
