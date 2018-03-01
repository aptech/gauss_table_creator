![gauss tables]

# GAUSS Table Creator
This package provides a set of tools for formatting, creating, and exporting publication quality tables in GAUSS. Table formatting can be controlled by directly setting members in the `tableControl` structure or through use of a series of `tableSet` functions.

## Getting Started
### Prerequisites
The program files require a working copy of GAUSS 18+. Many can be run on earlier versions with some small revisions.

### Installing
The GAUSS table creator can be easily installed using the GAUSS application installation wizard. This can be done following some very simple steps:
1. Download the zipped folder `tabout.zip`.
2. In GAUSS go to Tools>Install Application
![install wizard](gauss_table_creater/images/install_aplication.jpg)
3. Follow examples, making sure to navigate to the downloaded `tabout.zip`.
4. Before using the functions created by tabout you will need to load the newly created `tabout` library. This can be done in a number of ways:
  *   Navigate to the library tool view window and click the small wrench located next to the `tabout` library. Select `Load Library`.
  ![load library](gauss_table_creater/images/load library.jpg)
  *  Enter `library tabout` in the program input/output window.
  *  Put the line `library tabout;` at the beginning of your program files.

Note: I have provided the individual files found in `tabout.zip` for examination and review. However, installation should always be done using the `tabout.zip` folder and the Installation Wizard.

### Examples
After installing the library the example file will be found in your GAUSS home directory in the directory `\pkgs\tabout\examples`. The example uses a GAUSS dataset included with the GAUSS 18 examples. 

## Authors
*  Erica Clower - [Aptech Systems, Inc](www.aptech.com)
