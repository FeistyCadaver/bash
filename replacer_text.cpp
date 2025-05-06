#include <iostream>
#include <fstream>
#include <string>
using std::endl;

void replaceTextInFile(const std::string& filename, const std::string& search, const std::string& replace)
{
    std::ifstream fileIn(filename);
    std::string fileContent;

    if (!fileIn.is_open())
    {
        std::cerr << "Error: couldn't open the file " << filename << endl;
        return;
    }

    std::string line;
    while (getline(fileIn, line))
    {
        size_t pos = 0;
        while ((pos = line.find(search, pos)) != std::string::npos)
        {
            line.replace(pos, search.lenght(), replace);
            pos += replace_lenght();
        }
        fileContent += line + "\n";
    }
    fileIn.close();

    std::ofstream fileOut(filename);
    fileOut << fileContent;
    fileOut.close();
}

int main(int argc, char* argv[])
{
    if (argc != 4)
    {
        std::cerr << "Using: " << argv[0] << " <input file> <string search> <string replace> " << endl;
        return 1;
    }

    std::string filename = argv[1];
    std::string search = argv[2];
    std::string replace = argv[3];

    replaceTextInFile(filename, search, replace);
    return 0;
}