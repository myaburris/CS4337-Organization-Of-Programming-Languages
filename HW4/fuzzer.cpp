#include <iostream>
#include <fstream>
#include <string>
#include <time.h>
#include <stdlib.h>

using namespace std;

//mutation fuzzing function prototypes
void mutationFuzzing(int, string, string, string, string);
string mutate(string);
string changeChar(string);
string insertChar(string);
string deleteChar(string);

//generation fuzzing function prototypes
void generationFuzzing();
string generateValues(string);

int main(){
    //input
    string test1= "19037";
    string test2 = "143.0908";
    string test3 = "-798";
    string test4 = "0";

    //mutation fuzzing
    //mutationFuzzing(1, test1, test2, test3, test4);

    //generation fuzzing
    generationFuzzing();

    return 0;
}

/*
* mutation fuzzing function
*/
void mutationFuzzing (int n, string input1, string input2, string input3, string input4){
    fstream mutationFile;
    for (int i = 1; i <= n; i++){
        string mutation;
        mutationFile.open("test" + to_string(i) + ".txt", ios::out);
        srand(time(NULL));
        int base = rand() % 4 + 1;
        switch(base){
            case 1:
                mutation = mutate(input1);
                break;
            case 2:
                mutation = mutate(input2);
                break;
            case 3:
                mutation = mutate(input3);
                break;
            case 4:
                mutation = mutate(input4);
                break;
            default:
                cout << "Invalid base value" << endl;
                exit(EXIT_FAILURE);
        }
        mutationFile.seekp(0);
        mutationFile << mutation;
        mutationFile.close();
    }
}

/*
* mutates the input string
*/
string mutate(string input) {
    int choice = rand() % 3 + 1;
    switch (choice){
        case 1:
            return changeChar(input);
            break;
        case 2:
            return insertChar(input);
            break;
        case 3:
            return deleteChar(input);
            break;
        default:
            cout << "Invalid choice" << endl;
            exit(EXIT_FAILURE);
    }
}

/*
 *  changes a random character
*/
string changeChar(string input){
    char chars[] = {'0', '1', '2', '3', '4', '5', '6', '7', '8', '9', '+', '-', '.', ','};
    int index = rand() % input.length(); 
    int choice = rand() % 13;
    input[index] = chars[choice];
    return input;
}

/*
 * adds a new character
*/
string insertChar(string input){
    string chars[] = {"0", "1", "2", "3", "4", "5", "6", "7", "8", "9", "+", "-", ".", ","};
    int index = rand() % input.length(); 
    int choice = rand() % 13;
    input.insert(index, chars[choice]);
    return input;
}

/*
 * deletes a character 
*/
string deleteChar(string input){
    int index = rand() % input.length(); 
    input.erase(index, 1);
    return input;
}

/*
 * generation fuzzing 
*/
void generationFuzzing(){
    fstream generationFile;
    string input = "0";
    generationFile.open("genTest.txt", ios::out);
    srand(time(NULL));
    int range = rand() % 10000000000000000000;
    for (int i = 0; i <= range; i++){
        input = generateValues(input);
    }
    generationFile.seekp(0);
    generationFile << input;
    generationFile.close();
}

/*
 * generates input values
*/
string generateValues(string input){
    string chars[] = {"0", "1", "2", "3", "4", "5", "6", "7", "8", "9", "+", "-", ".", ","};
    int index = rand() % input.length(); 
    int choice = rand() % 13;
    if (choice >= 0 && choice <= 9)
        input.insert(index, chars[choice]);
    else{
        double chance = rand()/RAND_MAX;
        if (chance > 0.6) 
            input.insert(index, "+");
        if (chance > 0.3)
            input.insert(index, "-");
        if (chance > 0.1)
            input.insert(index, ".");
        if (chance > 0.5)
            input.insert(index, ",");
    }
    return input;
}