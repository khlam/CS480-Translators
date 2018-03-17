#include "ast.h"

Node *newNode(string name)
{
    Node *tmp = new Node;
    tmp->name = name;
    return tmp;
}

Node *newNode(string name, string value)
{
    Node *tmp = new Node;
    tmp->name = name;
    boost::erase_all(value, ".0"); // Terrible solution to remove trailing zeros.
    tmp->value = value;            // A real implimentation will need to remove this.
    return tmp;
}

void print_all(Node * n, string parent, string side)
{
    if (n != NULL)
    {
        string child = ""; // Declare and reset child string just incase
        if (n->type == 0 && (n->childs.size() == 2)) // Assignment Logic
        {
            child = parent + side; // current position
            if (parent != child) // Prevents double printing Root Block to 
            {                    // child assignment association
                cout << "  " << parent << " -> " << child << ";" << endl; 
            }
            cout << "  " << child << " [label=\""<< n->name << "\"];" << endl;
            print_all(n->childs[0], child, "_lhs"); // Left child
            print_all(n->childs[1], child, "_rhs"); // Right child
        }
        else if (n->type == 1) // If-block logic
        {
            child = parent + side;
            cout << "  " << child << " [label=\"If\"];" << endl;
            print_all(n->childs[0], child, "_cond");
            int i;
            for (i = 1; i < n->childs.size(); i++)
            {
                print_all(n->childs[i], child, "_if");
            }
        }
        else if (n->childs.size() == 0) // Terminals 
        {   // Print below if there are no children
            string my_name = parent + side;
            if (parent != my_name)
            {
                cout << "  " << parent << " -> " << my_name << ";" << endl; 
            }
            if (n->type != 7)
            {
                cout << "  " << my_name << " [shape=box,label=\"" << n->name << n->value << "\"];" << endl;
            }
            else
            {
                cout << "  " << my_name << " [label=\"Break\"];" << endl;
            }
        }
        else if (n->type == 4) // Block Logic
        {
            string my_name = parent + side;
            if (parent.compare("n0") != 0 && (parent != my_name))
            {
                cout << "  " << parent << " -> " << my_name << ";" << endl;
            }
            cout << "  " << my_name << " [label=\"Block\"];" << endl;
            int i;
            for (i = 0; i < n->childs.size(); i++)
            {
                child = my_name + "_" + to_string(i);
                cout << "  " << my_name << " -> " << child << ";" << endl;
                print_all(n->childs[i], child, "");
            }
        }
        else if (n->type == 5 && n->childs.size() == 1) // Else Logic
        {
            string my_name = parent + "_else";
            cout << "  " << parent << " -> " << my_name << ";" << endl;
            print_all(n->childs[0], my_name, "");
        }
        else if (n->type == 6) // While Logic
        {
            child = parent + side;
            cout << "  " << child << " [label=\"While\"];" << endl;
            print_all(n->childs[0], child, "_cond");
            int i;
            for (i = 1; i < n->childs.size(); i++)
            {
                print_all(n->childs[i], child, "_while");
            }
        }
    }
}
