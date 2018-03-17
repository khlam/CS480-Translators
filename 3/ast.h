#ifndef AST_H
#define AST_H

#include <iostream>
#include <string>
#include <vector>
#include <boost/algorithm/string.hpp>

using namespace std;

struct Node {
    int type;
    string name;
    string value;
    vector<Node *> childs;
};

Node *newNode(string name);
Node *newNode(string name, string value);
void print_all(Node * n, string parent, string side);

#endif