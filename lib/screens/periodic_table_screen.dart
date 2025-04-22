import 'package:flutter/material.dart';
import 'element_detail_screen.dart';

class PeriodicTableScreen extends StatelessWidget {
  const PeriodicTableScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Periodic Table'),
        backgroundColor: Colors.blueGrey[800],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              const SizedBox(height: 10),
              Container(
                alignment: Alignment.center,
                padding: const EdgeInsets.all(8.0),
                child: const Text(
                  'Periodic Table of Elements',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 10),
              InteractiveViewer(
                minScale: 0.5,
                maxScale: 2.5,
                child: _buildPeriodicTable(context),
              ),
              const SizedBox(height: 20),
              _buildLegend(),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLegend() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Wrap(
        spacing: 10,
        runSpacing: 10,
        alignment: WrapAlignment.center,
        children: [
          _legendItem(Color(0xFFD4F1F9), 'Alkali Metals'),
          _legendItem(Color(0xFFFDDAE1), 'Alkaline Earth Metals'),
          _legendItem(Color(0xFFE6E6FA), 'Transition Metals'),
          _legendItem(Color(0xFFD9EAD3), 'Post-transition Metals'),
          _legendItem(Color(0xFFFFF2CC), 'Metalloids'),
          _legendItem(Color(0xFFDEEBF7), 'Nonmetals'),
          _legendItem(Color(0xFFF9CBDF), 'Halogens'),
          _legendItem(Color(0xFFFCE5CD), 'Noble Gases'),
          _legendItem(Color(0xFFDAD2E9), 'Lanthanides'),
          _legendItem(Color(0xFFFEE5D9), 'Actinides'),
        ],
      ),
    );
  }

  Widget _legendItem(Color color, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 20,
          height: 20,
          color: color,
        ),
        const SizedBox(width: 5),
        Text(text, style: const TextStyle(fontSize: 12)),
      ],
    );
  }

  Widget _buildPeriodicTable(BuildContext context) {
    return Table(
      defaultColumnWidth: const FixedColumnWidth(60),
      defaultVerticalAlignment: TableCellVerticalAlignment.middle,
      children: [
        // Row 1
        TableRow(children: [
          _elementButton(context, 'H', '1', 'Hydrogen', Color(0xFFD4F1F9)),
          _emptyCell(),
          _emptyCell(),
          _emptyCell(),
          _emptyCell(),
          _emptyCell(),
          _emptyCell(),
          _emptyCell(),
          _emptyCell(),
          _emptyCell(),
          _emptyCell(),
          _emptyCell(),
          _emptyCell(),
          _emptyCell(),
          _emptyCell(),
          _emptyCell(),
          _emptyCell(),
          _elementButton(context, 'He', '2', 'Helium', Color(0xFFFCE5CD)),
        ]),
        
        // Row 2
        TableRow(children: [
          _elementButton(context, 'Li', '3', 'Lithium', Color(0xFFD4F1F9)),
          _elementButton(context, 'Be', '4', 'Beryllium', Color(0xFFFDDAE1)),
          _emptyCell(),
          _emptyCell(),
          _emptyCell(),
          _emptyCell(),
          _emptyCell(),
          _emptyCell(),
          _emptyCell(),
          _emptyCell(),
          _emptyCell(),
          _emptyCell(),
          _elementButton(context, 'B', '5', 'Boron', Color(0xFFFFF2CC)),
          _elementButton(context, 'C', '6', 'Carbon', Color(0xFFDEEBF7)),
          _elementButton(context, 'N', '7', 'Nitrogen', Color(0xFFDEEBF7)),
          _elementButton(context, 'O', '8', 'Oxygen', Color(0xFFDEEBF7)),
          _elementButton(context, 'F', '9', 'Fluorine', Color(0xFFF9CBDF)),
          _elementButton(context, 'Ne', '10', 'Neon', Color(0xFFFCE5CD)),
        ]),
        
        // Row 3
        TableRow(children: [
          _elementButton(context, 'Na', '11', 'Sodium', Color(0xFFD4F1F9)),
          _elementButton(context, 'Mg', '12', 'Magnesium', Color(0xFFFDDAE1)),
          _emptyCell(),
          _emptyCell(),
          _emptyCell(),
          _emptyCell(),
          _emptyCell(),
          _emptyCell(),
          _emptyCell(),
          _emptyCell(),
          _emptyCell(),
          _emptyCell(),
          _elementButton(context, 'Al', '13', 'Aluminum', Color(0xFFD9EAD3)),
          _elementButton(context, 'Si', '14', 'Silicon', Color(0xFFFFF2CC)),
          _elementButton(context, 'P', '15', 'Phosphorus', Color(0xFFDEEBF7)),
          _elementButton(context, 'S', '16', 'Sulfur', Color(0xFFDEEBF7)),
          _elementButton(context, 'Cl', '17', 'Chlorine', Color(0xFFF9CBDF)),
          _elementButton(context, 'Ar', '18', 'Argon', Color(0xFFFCE5CD)),
        ]),
        
        // Row 4
        TableRow(children: [
          _elementButton(context, 'K', '19', 'Potassium', Color(0xFFD4F1F9)),
          _elementButton(context, 'Ca', '20', 'Calcium', Color(0xFFFDDAE1)),
          _elementButton(context, 'Sc', '21', 'Scandium', Color(0xFFE6E6FA)),
          _elementButton(context, 'Ti', '22', 'Titanium', Color(0xFFE6E6FA)),
          _elementButton(context, 'V', '23', 'Vanadium', Color(0xFFE6E6FA)),
          _elementButton(context, 'Cr', '24', 'Chromium', Color(0xFFE6E6FA)),
          _elementButton(context, 'Mn', '25', 'Manganese', Color(0xFFE6E6FA)),
          _elementButton(context, 'Fe', '26', 'Iron', Color(0xFFE6E6FA)),
          _elementButton(context, 'Co', '27', 'Cobalt', Color(0xFFE6E6FA)),
          _elementButton(context, 'Ni', '28', 'Nickel', Color(0xFFE6E6FA)),
          _elementButton(context, 'Cu', '29', 'Copper', Color(0xFFE6E6FA)),
          _elementButton(context, 'Zn', '30', 'Zinc', Color(0xFFE6E6FA)),
          _elementButton(context, 'Ga', '31', 'Gallium', Color(0xFFD9EAD3)),
          _elementButton(context, 'Ge', '32', 'Germanium', Color(0xFFFFF2CC)),
          _elementButton(context, 'As', '33', 'Arsenic', Color(0xFFFFF2CC)),
          _elementButton(context, 'Se', '34', 'Selenium', Color(0xFFDEEBF7)),
          _elementButton(context, 'Br', '35', 'Bromine', Color(0xFFF9CBDF)),
          _elementButton(context, 'Kr', '36', 'Krypton', Color(0xFFFCE5CD)),
        ]),
        
        // Row 5
        TableRow(children: [
          _elementButton(context, 'Rb', '37', 'Rubidium', Color(0xFFD4F1F9)),
          _elementButton(context, 'Sr', '38', 'Strontium', Color(0xFFFDDAE1)),
          _elementButton(context, 'Y', '39', 'Yttrium', Color(0xFFE6E6FA)),
          _elementButton(context, 'Zr', '40', 'Zirconium', Color(0xFFE6E6FA)),
          _elementButton(context, 'Nb', '41', 'Niobium', Color(0xFFE6E6FA)),
          _elementButton(context, 'Mo', '42', 'Molybdenum', Color(0xFFE6E6FA)),
          _elementButton(context, 'Tc', '43', 'Technetium', Color(0xFFE6E6FA)),
          _elementButton(context, 'Ru', '44', 'Ruthenium', Color(0xFFE6E6FA)),
          _elementButton(context, 'Rh', '45', 'Rhodium', Color(0xFFE6E6FA)),
          _elementButton(context, 'Pd', '46', 'Palladium', Color(0xFFE6E6FA)),
          _elementButton(context, 'Ag', '47', 'Silver', Color(0xFFE6E6FA)),
          _elementButton(context, 'Cd', '48', 'Cadmium', Color(0xFFE6E6FA)),
          _elementButton(context, 'In', '49', 'Indium', Color(0xFFD9EAD3)),
          _elementButton(context, 'Sn', '50', 'Tin', Color(0xFFD9EAD3)),
          _elementButton(context, 'Sb', '51', 'Antimony', Color(0xFFFFF2CC)),
          _elementButton(context, 'Te', '52', 'Tellurium', Color(0xFFFFF2CC)),
          _elementButton(context, 'I', '53', 'Iodine', Color(0xFFF9CBDF)),
          _elementButton(context, 'Xe', '54', 'Xenon', Color(0xFFFCE5CD)),
        ]),
        
        // Row 6 (with lanthanide indicator)
        TableRow(children: [
          _elementButton(context, 'Cs', '55', 'Cesium', Color(0xFFD4F1F9)),
          _elementButton(context, 'Ba', '56', 'Barium', Color(0xFFFDDAE1)),
          _elementButton(context, 'La', '57', 'Lanthanum', Color(0xFFDAD2E9)),
          _elementButton(context, 'Hf', '72', 'Hafnium', Color(0xFFE6E6FA)),
          _elementButton(context, 'Ta', '73', 'Tantalum', Color(0xFFE6E6FA)),
          _elementButton(context, 'W', '74', 'Tungsten', Color(0xFFE6E6FA)),
          _elementButton(context, 'Re', '75', 'Rhenium', Color(0xFFE6E6FA)),
          _elementButton(context, 'Os', '76', 'Osmium', Color(0xFFE6E6FA)),
          _elementButton(context, 'Ir', '77', 'Iridium', Color(0xFFE6E6FA)),
          _elementButton(context, 'Pt', '78', 'Platinum', Color(0xFFE6E6FA)),
          _elementButton(context, 'Au', '79', 'Gold', Color(0xFFE6E6FA)),
          _elementButton(context, 'Hg', '80', 'Mercury', Color(0xFFE6E6FA)),
          _elementButton(context, 'Tl', '81', 'Thallium', Color(0xFFD9EAD3)),
          _elementButton(context, 'Pb', '82', 'Lead', Color(0xFFD9EAD3)),
          _elementButton(context, 'Bi', '83', 'Bismuth', Color(0xFFD9EAD3)),
          _elementButton(context, 'Po', '84', 'Polonium', Color(0xFFFFF2CC)),
          _elementButton(context, 'At', '85', 'Astatine', Color(0xFFF9CBDF)),
          _elementButton(context, 'Rn', '86', 'Radon', Color(0xFFFCE5CD)),
        ]),
        
        // Row 7 (with actinide indicator)
        TableRow(children: [
          _elementButton(context, 'Fr', '87', 'Francium', Color(0xFFD4F1F9)),
          _elementButton(context, 'Ra', '88', 'Radium', Color(0xFFFDDAE1)),
          _elementButton(context, 'Ac', '89', 'Actinium', Color(0xFFFEE5D9)),
          _elementButton(context, 'Rf', '104', 'Rutherfordium', Color(0xFFE6E6FA)),
          _elementButton(context, 'Db', '105', 'Dubnium', Color(0xFFE6E6FA)),
          _elementButton(context, 'Sg', '106', 'Seaborgium', Color(0xFFE6E6FA)),
          _elementButton(context, 'Bh', '107', 'Bohrium', Color(0xFFE6E6FA)),
          _elementButton(context, 'Hs', '108', 'Hassium', Color(0xFFE6E6FA)),
          _elementButton(context, 'Mt', '109', 'Meitnerium', Color(0xFFE6E6FA)),
          _elementButton(context, 'Ds', '110', 'Darmstadtium', Color(0xFFE6E6FA)),
          _elementButton(context, 'Rg', '111', 'Roentgenium', Color(0xFFE6E6FA)),
          _elementButton(context, 'Cn', '112', 'Copernicium', Color(0xFFE6E6FA)),
          _elementButton(context, 'Nh', '113', 'Nihonium', Color(0xFFD9EAD3)),
          _elementButton(context, 'Fl', '114', 'Flerovium', Color(0xFFD9EAD3)),
          _elementButton(context, 'Mc', '115', 'Moscovium', Color(0xFFD9EAD3)),
          _elementButton(context, 'Lv', '116', 'Livermorium', Color(0xFFD9EAD3)),
          _elementButton(context, 'Ts', '117', 'Tennessine', Color(0xFFF9CBDF)),
          _elementButton(context, 'Og', '118', 'Oganesson', Color(0xFFFCE5CD)),
        ]),
        
        // Empty row for spacing
        TableRow(children: List.generate(18, (_) => SizedBox(height: 20))),
        
        // Lanthanides Row (f-block)
        TableRow(children: [
          _emptyCell(),
          _emptyCell(),
          _elementButton(context, 'Ce', '58', 'Cerium', Color(0xFFDAD2E9)),
          _elementButton(context, 'Pr', '59', 'Praseodymium', Color(0xFFDAD2E9)),
          _elementButton(context, 'Nd', '60', 'Neodymium', Color(0xFFDAD2E9)),
          _elementButton(context, 'Pm', '61', 'Promethium', Color(0xFFDAD2E9)),
          _elementButton(context, 'Sm', '62', 'Samarium', Color(0xFFDAD2E9)),
          _elementButton(context, 'Eu', '63', 'Europium', Color(0xFFDAD2E9)),
          _elementButton(context, 'Gd', '64', 'Gadolinium', Color(0xFFDAD2E9)),
          _elementButton(context, 'Tb', '65', 'Terbium', Color(0xFFDAD2E9)),
          _elementButton(context, 'Dy', '66', 'Dysprosium', Color(0xFFDAD2E9)),
          _elementButton(context, 'Ho', '67', 'Holmium', Color(0xFFDAD2E9)),
          _elementButton(context, 'Er', '68', 'Erbium', Color(0xFFDAD2E9)),
          _elementButton(context, 'Tm', '69', 'Thulium', Color(0xFFDAD2E9)),
          _elementButton(context, 'Yb', '70', 'Ytterbium', Color(0xFFDAD2E9)),
          _elementButton(context, 'Lu', '71', 'Lutetium', Color(0xFFDAD2E9)),
          _emptyCell(),
          _emptyCell(),
        ]),
        
        // Actinides Row (f-block)
        TableRow(children: [
          _emptyCell(),
          _emptyCell(),
          _elementButton(context, 'Th', '90', 'Thorium', Color(0xFFFEE5D9)),
          _elementButton(context, 'Pa', '91', 'Protactinium', Color(0xFFFEE5D9)),
          _elementButton(context, 'U', '92', 'Uranium', Color(0xFFFEE5D9)),
          _elementButton(context, 'Np', '93', 'Neptunium', Color(0xFFFEE5D9)),
          _elementButton(context, 'Pu', '94', 'Plutonium', Color(0xFFFEE5D9)),
          _elementButton(context, 'Am', '95', 'Americium', Color(0xFFFEE5D9)),
          _elementButton(context, 'Cm', '96', 'Curium', Color(0xFFFEE5D9)),
          _elementButton(context, 'Bk', '97', 'Berkelium', Color(0xFFFEE5D9)),
          _elementButton(context, 'Cf', '98', 'Californium', Color(0xFFFEE5D9)),
          _elementButton(context, 'Es', '99', 'Einsteinium', Color(0xFFFEE5D9)),
          _elementButton(context, 'Fm', '100', 'Fermium', Color(0xFFFEE5D9)),
          _elementButton(context, 'Md', '101', 'Mendelevium', Color(0xFFFEE5D9)),
          _elementButton(context, 'No', '102', 'Nobelium', Color(0xFFFEE5D9)),
          _elementButton(context, 'Lr', '103', 'Lawrencium', Color(0xFFFEE5D9)),
          _emptyCell(),
          _emptyCell(),
        ]),
      ],
    );
  }

  Widget _emptyCell() {
    return const SizedBox(
      width: 60,
      height: 60,
    );
  }

  Widget _elementButton(BuildContext context, String symbol, String atomicNumber, String name, Color color) {
    return Container(
      margin: const EdgeInsets.all(1),
      width: 60,
      height: 60,
      child: Material(
        color: color,
        elevation: 2,
        borderRadius: BorderRadius.circular(4),
        child: InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ElementDetailScreen(
                  symbol: symbol,
                  name: name,
                  atomicNumber: atomicNumber,
                ),
              ),
            );
          },
          child: Padding(
            padding: const EdgeInsets.all(2.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  atomicNumber,
                  style: const TextStyle(fontSize: 9, color: Colors.black54),
                ),
                Text(
                  symbol,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  name,
                  style: const TextStyle(fontSize: 8),
                  textAlign: TextAlign.center,
                  overflow: TextOverflow.ellipsis,
                ),
              ],  
            ),
          ),
        ),
      ),
    );
  }
}