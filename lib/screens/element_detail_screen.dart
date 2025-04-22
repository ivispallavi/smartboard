import 'package:flutter/material.dart';
import 'dart:math' as math;

class ElementDetailScreen extends StatefulWidget {
  final String symbol;
  final String name;
  final String atomicNumber;

  const ElementDetailScreen({
    Key? key,
    required this.symbol,
    required this.name,
    required this.atomicNumber,
  }) : super(key: key);

  @override
  _ElementDetailScreenState createState() => _ElementDetailScreenState();
}

class _ElementDetailScreenState extends State<ElementDetailScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  final Map<String, Map<String, dynamic>> _elementData = {
    "H": {
      "atomicMass": "1.008",
      "category": "Reactive non-metals",
      "electronConfig": "1s¹",
      "electronegativity": "2.20",
      "meltingPoint": "-259.14°C",
      "boilingPoint": "-252.87°C",
      "density": "0.00008988 g/cm³",
      "discoveredBy": "Henry Cavendish",
      "discoveryYear": "1766",
      "electrons": 1,
      "protons": 1,
      "neutrons": 0
    },
    "He": {
      "atomicMass": "4.0026",
      "category": "Noble gases",
      "electronConfig": "1s²",
      "electronegativity": "N/A",
      "meltingPoint": "-272.2°C",
      "boilingPoint": "-268.9°C",
      "density": "0.0001785 g/cm³",
      "discoveredBy": "Pierre Janssen, Norman Lockyer",
      "discoveryYear": "1868",
      "electrons": 2,
      "protons": 2,
      "neutrons": 2
    },
    "Li": {
      "atomicMass": "6.94",
      "category": "Alkali metals",
      "electronConfig": "1s² 2s¹",
      "electronegativity": "0.98",
      "meltingPoint": "180.5°C",
      "boilingPoint": "1342°C",
      "density": "0.534 g/cm³",
      "discoveredBy": "Johan August Arfwedson",
      "discoveryYear": "1817",
      "electrons": 3,
      "protons": 3,
      "neutrons": 4
    },
    "Be": {
      "atomicMass": "9.0122",
      "category": "Alkaline earth metals",
      "electronConfig": "1s² 2s²",
      "electronegativity": "1.57",
      "meltingPoint": "1287°C",
      "boilingPoint": "2470°C",
      "density": "1.85 g/cm³",
      "discoveredBy": "Louis Nicolas Vauquelin",
      "discoveryYear": "1797",
      "electrons": 4,
      "protons": 4,
      "neutrons": 5
    },
    "B": {
      "atomicMass": "10.81",
      "category": "Metalloids",
      "electronConfig": "1s² 2s² 2p¹",
      "electronegativity": "2.04",
      "meltingPoint": "2075°C",
      "boilingPoint": "4000°C",
      "density": "2.34 g/cm³",
      "discoveredBy": "Joseph Louis Gay-Lussac, Louis Jacques Thénard",
      "discoveryYear": "1808",
      "electrons": 5,
      "protons": 5,
      "neutrons": 6
    },
    "C": {
      "atomicMass": "12.011",
      "category": "Reactive non-metals",
      "electronConfig": "1s² 2s² 2p²",
      "electronegativity": "2.55",
      "meltingPoint": "3550°C",
      "boilingPoint": "4027°C",
      "density": "2.26 g/cm³",
      "discoveredBy": "Known since ancient times",
      "discoveryYear": "Ancient",
      "electrons": 6,
      "protons": 6,
      "neutrons": 6
    },
    "N": {
      "atomicMass": "14.007",
      "category": "Reactive non-metals",
      "electronConfig": "1s² 2s² 2p³",
      "electronegativity": "3.04",
      "meltingPoint": "-210.1°C",
      "boilingPoint": "-195.8°C",
      "density": "0.001251 g/cm³",
      "discoveredBy": "Daniel Rutherford",
      "discoveryYear": "1772",
      "electrons": 7,
      "protons": 7,
      "neutrons": 7
    },
    "O": {
      "atomicMass": "15.999",
      "category": "Reactive non-metals",
      "electronConfig": "1s² 2s² 2p⁴",
      "electronegativity": "3.44",
      "meltingPoint": "-218.3°C",
      "boilingPoint": "-183°C",
      "density": "0.001429 g/cm³",
      "discoveredBy": "Carl Wilhelm Scheele",
      "discoveryYear": "1774",
      "electrons": 8,
      "protons": 8,
      "neutrons": 8
    },
    "F": {
      "atomicMass": "18.998",
      "category": "Reactive non-metals",
      "electronConfig": "1s² 2s² 2p⁵",
      "electronegativity": "3.98",
      "meltingPoint": "-220°C",
      "boilingPoint": "-188.1°C",
      "density": "0.001696 g/cm³",
      "discoveredBy": "Henri Moissan",
      "discoveryYear": "1886",
      "electrons": 9,
      "protons": 9,
      "neutrons": 10
    },
    "Ne": {
      "atomicMass": "20.180",
      "category": "Noble gases",
      "electronConfig": "1s² 2s² 2p⁶",
      "electronegativity": "N/A",
      "meltingPoint": "-248.6°C",
      "boilingPoint": "-246.1°C",
      "density": "0.0008999 g/cm³",
      "discoveredBy": "William Ramsay, Morris Travers",
      "discoveryYear": "1898",
      "electrons": 10,
      "protons": 10,
      "neutrons": 10
    },
    "Na": {
      "atomicMass": "22.990",
      "category": "Alkali metals",
      "electronConfig": "1s² 2s² 2p⁶ 3s¹",
      "electronegativity": "0.93",
      "meltingPoint": "97.72°C",
      "boilingPoint": "883°C",
      "density": "0.971 g/cm³",
      "discoveredBy": "Humphry Davy",
      "discoveryYear": "1807",
      "electrons": 11,
      "protons": 11,
      "neutrons": 12
    },
    "Mg": {
      "atomicMass": "24.305",
      "category": "Alkaline earth metals",
      "electronConfig": "1s² 2s² 2p⁶ 3s²",
      "electronegativity": "1.31",
      "meltingPoint": "650°C",
      "boilingPoint": "1090°C",
      "density": "1.738 g/cm³",
      "discoveredBy": "Joseph Black",
      "discoveryYear": "1755",
      "electrons": 12,
      "protons": 12,
      "neutrons": 12
    },
    "Al": {
      "atomicMass": "26.982",
      "category": "Post-transition metals",
      "electronConfig": "1s² 2s² 2p⁶ 3s² 3p¹",
      "electronegativity": "1.61",
      "meltingPoint": "660.32°C",
      "boilingPoint": "2519°C",
      "density": "2.7 g/cm³",
      "discoveredBy": "Hans Christian Ørsted",
      "discoveryYear": "1825",
      "electrons": 13,
      "protons": 13,
      "neutrons": 14
    },
    "Si": {
      "atomicMass": "28.085",
      "category": "Metalloids",
      "electronConfig": "1s² 2s² 2p⁶ 3s² 3p²",
      "electronegativity": "1.90",
      "meltingPoint": "1414°C",
      "boilingPoint": "3265°C",
      "density": "2.33 g/cm³",
      "discoveredBy": "Jöns Jacob Berzelius",
      "discoveryYear": "1824",
      "electrons": 14,
      "protons": 14,
      "neutrons": 14
    },
    "P": {
      "atomicMass": "30.974",
      "category": "Reactive non-metals",
      "electronConfig": "1s² 2s² 2p⁶ 3s² 3p³",
      "electronegativity": "2.19",
      "meltingPoint": "44.2°C",
      "boilingPoint": "280.5°C",
      "density": "1.82 g/cm³",
      "discoveredBy": "Hennig Brand",
      "discoveryYear": "1669",
      "electrons": 15,
      "protons": 15,
      "neutrons": 16
    },
    "S": {
      "atomicMass": "32.06",
      "category": "Reactive non-metals",
      "electronConfig": "1s² 2s² 2p⁶ 3s² 3p⁴",
      "electronegativity": "2.58",
      "meltingPoint": "115.21°C",
      "boilingPoint": "444.72°C",
      "density": "2.07 g/cm³",
      "discoveredBy": "Known since ancient times",
      "discoveryYear": "Ancient",
      "electrons": 16,
      "protons": 16,
      "neutrons": 16
    },
    "Cl": {
      "atomicMass": "35.45",
      "category": "Reactive non-metals",
      "electronConfig": "1s² 2s² 2p⁶ 3s² 3p⁵",
      "electronegativity": "3.16",
      "meltingPoint": "-101.5°C",
      "boilingPoint": "-34.04°C",
      "density": "0.003214 g/cm³",
      "discoveredBy": "Carl Wilhelm Scheele",
      "discoveryYear": "1774",
      "electrons": 17,
      "protons": 17,
      "neutrons": 18
    },
    "Ar": {
      "atomicMass": "39.948",
      "category": "Noble gases",
      "electronConfig": "1s² 2s² 2p⁶ 3s² 3p⁶",
      "electronegativity": "N/A",
      "meltingPoint": "-189.34°C",
      "boilingPoint": "-185.85°C",
      "density": "0.0017837 g/cm³",
      "discoveredBy": "Lord Rayleigh, William Ramsay",
      "discoveryYear": "1894",
      "electrons": 18,
      "protons": 18,
      "neutrons": 22
    },
    "K": {
      "atomicMass": "39.098",
      "category": "Alkali metals",
      "electronConfig": "1s² 2s² 2p⁶ 3s² 3p⁶ 4s¹",
      "electronegativity": "0.82",
      "meltingPoint": "63.38°C",
      "boilingPoint": "759°C",
      "density": "0.862 g/cm³",
      "discoveredBy": "Humphry Davy",
      "discoveryYear": "1807",
      "electrons": 19,
      "protons": 19,
      "neutrons": 20
    },
    "Ca": {
      "atomicMass": "40.078",
      "category": "Alkaline earth metals",
      "electronConfig": "1s² 2s² 2p⁶ 3s² 3p⁶ 4s²",
      "electronegativity": "1.00",
      "meltingPoint": "842°C",
      "boilingPoint": "1484°C",
      "density": "1.54 g/cm³",
      "discoveredBy": "Humphry Davy",
      "discoveryYear": "1808",
      "electrons": 20,
      "protons": 20,
      "neutrons": 20
    },
    "Sc": {
      "atomicMass": "44.956",
      "category": "Transition metals",
      "electronConfig": "1s² 2s² 2p⁶ 3s² 3p⁶ 4s² 3d¹",
      "electronegativity": "1.36",
      "meltingPoint": "1541°C",
      "boilingPoint": "2830°C",
      "density": "2.99 g/cm³",
      "discoveredBy": "Lars Fredrik Nilson",
      "discoveryYear": "1879",
      "electrons": 21,
      "protons": 21,
      "neutrons": 24
    },
    "Ti": {
      "atomicMass": "47.867",
      "category": "Transition metals",
      "electronConfig": "1s² 2s² 2p⁶ 3s² 3p⁶ 4s² 3d²",
      "electronegativity": "1.54",
      "meltingPoint": "1668°C",
      "boilingPoint": "3287°C",
      "density": "4.5 g/cm³",
      "discoveredBy": "William Gregor",
      "discoveryYear": "1791",
      "electrons": 22,
      "protons": 22,
      "neutrons": 26
    },
    "V": {
      "atomicMass": "50.942",
      "category": "Transition metals",
      "electronConfig": "1s² 2s² 2p⁶ 3s² 3p⁶ 4s² 3d³",
      "electronegativity": "1.63",
      "meltingPoint": "1910°C",
      "boilingPoint": "3407°C",
      "density": "6.0 g/cm³",
      "discoveredBy": "Andrés Manuel del Río",
      "discoveryYear": "1801",
      "electrons": 23,
      "protons": 23,
      "neutrons": 28
    },
    "Cr": {
      "atomicMass": "51.996",
      "category": "Transition metals",
      "electronConfig": "1s² 2s² 2p⁶ 3s² 3p⁶ 4s¹ 3d⁵",
      "electronegativity": "1.66",
      "meltingPoint": "1907°C",
      "boilingPoint": "2671°C",
      "density": "7.15 g/cm³",
      "discoveredBy": "Louis Nicolas Vauquelin",
      "discoveryYear": "1797",
      "electrons": 24,
      "protons": 24,
      "neutrons": 28
    },
    "Mn": {
      "atomicMass": "54.938",
      "category": "Transition metals",
      "electronConfig": "1s² 2s² 2p⁶ 3s² 3p⁶ 4s² 3d⁵",
      "electronegativity": "1.55",
      "meltingPoint": "1246°C",
      "boilingPoint": "2061°C",
      "density": "7.3 g/cm³",
      "discoveredBy": "Johann Gottlieb Gahn",
      "discoveryYear": "1774",
      "electrons": 25,
      "protons": 25,
      "neutrons": 30
    },
    "Fe": {
      "atomicMass": "55.845",
      "category": "Transition metals",
      "electronConfig": "1s² 2s² 2p⁶ 3s² 3p⁶ 4s² 3d⁶",
      "electronegativity": "1.83",
      "meltingPoint": "1538°C",
      "boilingPoint": "2861°C",
      "density": "7.87 g/cm³",
      "discoveredBy": "Known since ancient times",
      "discoveryYear": "Ancient",
      "electrons": 26,
      "protons": 26,
      "neutrons": 30
    },
    "Co": {
      "atomicMass": "58.933",
      "category": "Transition metals",
      "electronConfig": "1s² 2s² 2p⁶ 3s² 3p⁶ 4s² 3d⁷",
      "electronegativity": "1.88",
      "meltingPoint": "1495°C",
      "boilingPoint": "2927°C",
      "density": "8.9 g/cm³",
      "discoveredBy": "Georg Brandt",
      "discoveryYear": "1735",
      "electrons": 27,
      "protons": 27,
      "neutrons": 32
    },
    "Ni": {
      "atomicMass": "58.693",
      "category": "Transition metals",
      "electronConfig": "1s² 2s² 2p⁶ 3s² 3p⁶ 4s² 3d⁸",
      "electronegativity": "1.91",
      "meltingPoint": "1455°C",
      "boilingPoint": "2913°C",
      "density": "8.9 g/cm³",
      "discoveredBy": "Axel Fredrik Cronstedt",
      "discoveryYear": "1751",
      "electrons": 28,
      "protons": 28,
      "neutrons": 31
    },
    "Cu": {
      "atomicMass": "63.546",
      "category": "Transition metals",
      "electronConfig": "1s² 2s² 2p⁶ 3s² 3p⁶ 4s¹ 3d¹⁰",
      "electronegativity": "1.90",
      "meltingPoint": "1084.6°C",
      "boilingPoint": "2562°C",
      "density": "8.96 g/cm³",
      "discoveredBy": "Known since ancient times",
      "discoveryYear": "Ancient",
      "electrons": 29,
      "protons": 29,
      "neutrons": 35
    },
    "Zn": {
      "atomicMass": "65.38",
      "category": "Transition metals",
      "electronConfig": "1s² 2s² 2p⁶ 3s² 3p⁶ 4s² 3d¹⁰",
      "electronegativity": "1.65",
      "meltingPoint": "419.5°C",
      "boilingPoint": "907°C",
      "density": "7.14 g/cm³",
      "discoveredBy": "Known since ancient times",
      "discoveryYear": "Ancient",
      "electrons": 30,
      "protons": 30,
      "neutrons": 35
    },
    "Ga": {
      "atomicMass": "69.723",
      "category": "Post-transition metals",
      "electronConfig": "1s² 2s² 2p⁶ 3s² 3p⁶ 4s² 3d¹⁰ 4p¹",
      "electronegativity": "1.81",
      "meltingPoint": "29.76°C",
      "boilingPoint": "2204°C",
      "density": "5.91 g/cm³",
      "discoveredBy": "Lecoq de Boisbaudran",
      "discoveryYear": "1875",
      "electrons": 31,
      "protons": 31,
      "neutrons": 39
    },
    "Ge": {
      "atomicMass": "72.630",
      "category": "Metalloids",
      "electronConfig": "1s² 2s² 2p⁶ 3s² 3p⁶ 4s² 3d¹⁰ 4p²",
      "electronegativity": "2.01",
      "meltingPoint": "938.3°C",
      "boilingPoint": "2833°C",
      "density": "5.32 g/cm³",
      "discoveredBy": "Clemens Winkler",
      "discoveryYear": "1886",
      "electrons": 32,
      "protons": 32,
      "neutrons": 41
    },
    "As": {
      "atomicMass": "74.922",
      "category": "Metalloids",
      "electronConfig": "1s² 2s² 2p⁶ 3s² 3p⁶ 4s² 3d¹⁰ 4p³",
      "electronegativity": "2.18",
      "meltingPoint": "816.9°C (at 28 atm)",
      "boilingPoint": "614°C (sublimation)",
      "density": "5.73 g/cm³",
      "discoveredBy": "Known since ancient times",
      "discoveryYear": "Ancient",
      "electrons": 33,
      "protons": 33,
      "neutrons": 42
    },
    "Se": {
      "atomicMass": "78.971",
      "category": "Reactive non-metals",
      "electronConfig": "1s² 2s² 2p⁶ 3s² 3p⁶ 4s² 3d¹⁰ 4p⁴",
      "electronegativity": "2.55",
      "meltingPoint": "221°C",
      "boilingPoint": "685°C",
      "density": "4.81 g/cm³",
      "discoveredBy": "Jöns Jacob Berzelius",
      "discoveryYear": "1817",
      "electrons": 34,
      "protons": 34,
      "neutrons": 45
    },
    "Br": {
      "atomicMass": "79.904",
      "category": "Reactive non-metals",
      "electronConfig": "1s² 2s² 2p⁶ 3s² 3p⁶ 4s² 3d¹⁰ 4p⁵",
      "electronegativity": "2.96",
      "meltingPoint": "-7.3°C",
      "boilingPoint": "58.8°C",
      "density": "3.12 g/cm³",
      "discoveredBy": "Antoine Jérôme Balard",
      "discoveryYear": "1826",
      "electrons": 35,
      "protons": 35,
      "neutrons": 45
    },
    "Kr": {
      "atomicMass": "83.798",
      "category": "Noble gases",
      "electronConfig": "1s² 2s² 2p⁶ 3s² 3p⁶ 4s² 3d¹⁰ 4p⁶",
      "electronegativity": "N/A",
      "meltingPoint": "-157.36°C",
      "boilingPoint": "-153.22°C",
      "density": "0.003733 g/cm³",
      "discoveredBy": "William Ramsay, Morris Travers",
      "discoveryYear": "1898",
      "electrons": 36,
      "protons": 36,
      "neutrons": 48
    },
    "Rb": {
      "atomicMass": "85.468",
      "category": "Alkali metals",
      "electronConfig": "1s² 2s² 2p⁶ 3s² 3p⁶ 4s² 3d¹⁰ 4p⁶ 5s¹",
      "electronegativity": "0.82",
      "meltingPoint": "39.31°C",
      "boilingPoint": "688°C",
      "density": "1.53 g/cm³",
      "discoveredBy": "Robert Bunsen, Gustav Kirchhoff",
      "discoveryYear": "1861",
      "electrons": 37,
      "protons": 37,
      "neutrons": 48
    },
    "Sr": {
      "atomicMass": "87.62",
      "category": "Alkaline earth metals",
      "electronConfig": "1s² 2s² 2p⁶ 3s² 3p⁶ 4s² 3d¹⁰ 4p⁶ 5s²",
      "electronegativity": "0.95",
      "meltingPoint": "777°C",
      "boilingPoint": "1377°C",
      "density": "2.64 g/cm³",
      "discoveredBy": "William Cruickshank",
      "discoveryYear": "1790",
      "electrons": 38,
      "protons": 38,
      "neutrons": 50
    },
    "Y": {
      "atomicMass": "88.906",
      "category": "Transition metals",
      "electronConfig": "1s² 2s² 2p⁶ 3s² 3p⁶ 4s² 3d¹⁰ 4p⁶ 5s² 4d¹",
      "electronegativity": "1.22",
      "meltingPoint": "1526°C",
      "boilingPoint": "3345°C",
      "density": "4.47 g/cm³",
      "discoveredBy": "Johan Gadolin",
      "discoveryYear": "1794",
      "electrons": 39,
      "protons": 39,
      "neutrons": 50
    },
    "Zr": {
      "atomicMass": "91.224",
      "category": "Transition metals",
      "electronConfig": "1s² 2s² 2p⁶ 3s² 3p⁶ 4s² 3d¹⁰ 4p⁶ 5s² 4d²",
      "electronegativity": "1.33",
      "meltingPoint": "1855°C",
      "boilingPoint": "4409°C",
      "density": "6.52 g/cm³",
      "discoveredBy": "Martin Heinrich Klaproth",
      "discoveryYear": "1789",
      "electrons": 40,
      "protons": 40,
      "neutrons": 51
    },
    "Nb": {
      "atomicMass": "92.906",
      "category": "Transition metals",
      "electronConfig": "1s² 2s² 2p⁶ 3s² 3p⁶ 4s² 3d¹⁰ 4p⁶ 5s¹ 4d⁴",
      "electronegativity": "1.6",
      "meltingPoint": "2477°C",
      "boilingPoint": "4744°C",
      "density": "8.57 g/cm³",
      "discoveredBy": "Charles Hatchett",
      "discoveryYear": "1801",
      "electrons": 41,
      "protons": 41,
      "neutrons": 52
    },
    "Mo": {
      "atomicMass": "95.95",
      "category": "Transition metals",
      "electronConfig": "1s² 2s² 2p⁶ 3s² 3p⁶ 4s² 3d¹⁰ 4p⁶ 5s¹ 4d⁵",
      "electronegativity": "2.16",
      "meltingPoint": "2623°C",
      "boilingPoint": "4639°C",
      "density": "10.28 g/cm³",
      "discoveredBy": "Carl Wilhelm Scheele",
      "discoveryYear": "1778",
      "electrons": 42,
      "protons": 42,
      "neutrons": 54
    },
    "Tc": {
      "atomicMass": "98.00",
      "category": "Transition metals",
      "electronConfig": "1s² 2s² 2p⁶ 3s² 3p⁶ 4s² 3d¹⁰ 4p⁶ 5s² 4d⁵",
      "electronegativity": "1.9",
      "meltingPoint": "2157°C",
      "boilingPoint": "4265°C",
      "density": "11.5 g/cm³",
      "discoveredBy": "Carlo Perrier, Emilio Segrè",
      "discoveryYear": "1937",
      "electrons": 43,
      "protons": 43,
      "neutrons": 55
    },
    "Ru": {
      "atomicMass": "101.07",
      "category": "Transition metals",
      "electronConfig": "1s² 2s² 2p⁶ 3s² 3p⁶ 4s² 3d¹⁰ 4p⁶ 5s¹ 4d⁷",
      "electronegativity": "2.2",
      "meltingPoint": "2334°C",
      "boilingPoint": "4150°C",
      "density": "12.37 g/cm³",
      "discoveredBy": "Karl Ernst Claus",
      "discoveryYear": "1844",
      "electrons": 44,
      "protons": 44,
      "neutrons": 57
    },
    "Rh": {
      "atomicMass": "102.91",
      "category": "Transition metals",
      "electronConfig": "1s² 2s² 2p⁶ 3s² 3p⁶ 4s² 3d¹⁰ 4p⁶ 5s¹ 4d⁸",
      "electronegativity": "2.28",
      "meltingPoint": "1964°C",
      "boilingPoint": "3695°C",
      "density": "12.41 g/cm³",
      "discoveredBy": "William Hyde Wollaston",
      "discoveryYear": "1803",
      "electrons": 45,
      "protons": 45,
      "neutrons": 58
    },
    "Pd": {
      "atomicMass": "106.42",
      "category": "Transition metals",
      "electronConfig": "1s² 2s² 2p⁶ 3s² 3p⁶ 4s² 3d¹⁰ 4p⁶ 4d¹⁰",
      "electronegativity": "2.20",
      "meltingPoint": "1554.9°C",
      "boilingPoint": "2963°C",
      "density": "12.02 g/cm³",
      "discoveredBy": "William Hyde Wollaston",
      "discoveryYear": "1803",
      "electrons": 46,
      "protons": 46,
      "neutrons": 60
    },
    "Ag": {
      "atomicMass": "107.87",
      "category": "Transition metals",
      "electronConfig": "1s² 2s² 2p⁶ 3s² 3p⁶ 4s² 3d¹⁰ 4p⁶ 5s¹ 4d¹⁰",
      "electronegativity": "1.93",
      "meltingPoint": "961.78°C",
      "boilingPoint": "2162°C",
      "density": "10.49 g/cm³",
      "discoveredBy": "Known since ancient times",
      "discoveryYear": "Ancient",
      "electrons": 47,
      "protons": 47,
      "neutrons": 61
    },
    "Cd": {
      "atomicMass": "112.41",
      "category": "Transition metals",
      "electronConfig": "1s² 2s² 2p⁶ 3s² 3p⁶ 4s² 3d¹⁰ 4p⁶ 5s² 4d¹⁰",
      "electronegativity": "1.69",
      "meltingPoint": "321.07°C",
      "boilingPoint": "767°C",
      "density": "8.65 g/cm³",
      "discoveredBy": "Karl Samuel Leberecht Hermann, Friedrich Stromeyer",
      "discoveryYear": "1817",
      "electrons": 48,
      "protons": 48,
      "neutrons": 64
    },
    "In": {
      "atomicMass": "114.82",
      "category": "Post-transition metals",
      "electronConfig": "1s² 2s² 2p⁶ 3s² 3p⁶ 4s² 3d¹⁰ 4p⁶ 5s² 4d¹⁰ 5p¹",
      "electronegativity": "1.78",
      "meltingPoint": "156.6°C",
      "boilingPoint": "2072°C",
      "density": "7.31 g/cm³",
      "discoveredBy": "Ferdinand Reich, Hieronymous Theodor Richter",
      "discoveryYear": "1863",
      "electrons": 49,
      "protons": 49,
      "neutrons": 66
    },
    "Sn": {
      "atomicMass": "118.71",
      "category": "Post-transition metals",
      "electronConfig": "1s² 2s² 2p⁶ 3s² 3p⁶ 4s² 3d¹⁰ 4p⁶ 5s² 4d¹⁰ 5p²",
      "electronegativity": "1.96",
      "meltingPoint": "231.93°C",
      "boilingPoint": "2602°C",
      "density": "7.287 g/cm³",
      "discoveredBy": "Known since ancient times",
      "discoveryYear": "Ancient",
      "electrons": 50,
      "protons": 50,
      "neutrons": 69
    },
    "Sb": {
      "atomicMass": "121.76",
      "category": "Metalloids",
      "electronConfig": "1s² 2s² 2p⁶ 3s² 3p⁶ 4s² 3d¹⁰ 4p⁶ 5s² 4d¹⁰ 5p³",
      "electronegativity": "2.05",
      "meltingPoint": "630.63°C",
      "boilingPoint": "1587°C",
      "density": "6.685 g/cm³",
      "discoveredBy": "Known since ancient times",
      "discoveryYear": "Ancient",
      "electrons": 51,
      "protons": 51,
      "neutrons": 71
    },
    "Te": {
      "atomicMass": "127.60",
      "category": "Metalloids",
      "electronConfig": "1s² 2s² 2p⁶ 3s² 3p⁶ 4s² 3d¹⁰ 4p⁶ 5s² 4d¹⁰ 5p⁴",
      "electronegativity": "2.1",
      "meltingPoint": "449.51°C",
      "boilingPoint": "988°C",
      "density": "6.232 g/cm³",
      "discoveredBy": "Franz-Joseph Müller von Reichenstein",
      "discoveryYear": "1782",
      "electrons": 52,
      "protons": 52,
      "neutrons": 76
    },
    "I": {
      "atomicMass": "126.90",
      "category": "Reactive non-metals",
      "electronConfig": "1s² 2s² 2p⁶ 3s² 3p⁶ 4s² 3d¹⁰ 4p⁶ 5s² 4d¹⁰ 5p⁵",
      "electronegativity": "2.66",
      "meltingPoint": "113.7°C",
      "boilingPoint": "184.3°C",
      "density": "4.933 g/cm³",
      "discoveredBy": "Bernard Courtois",
      "discoveryYear": "1811",
      "electrons": 53,
      "protons": 53,
      "neutrons": 74
    },
    "Xe": {
      "atomicMass": "131.29",
      "category": "Noble gases",
      "electronConfig": "1s² 2s² 2p⁶ 3s² 3p⁶ 4s² 3d¹⁰ 4p⁶ 5s² 4d¹⁰ 5p⁶",
      "electronegativity": "N/A",
      "meltingPoint": "-111.8°C",
      "boilingPoint": "-108.1°C",
      "density": "0.005887 g/cm³",
      "discoveredBy": "William Ramsay, Morris Travers",
      "discoveryYear": "1898",
      "electrons": 54,
      "protons": 54,
      "neutrons": 77
    },
    "Cs": {
      "atomicMass": "132.91",
      "category": "Alkali metals",
      "electronConfig": "1s² 2s² 2p⁶ 3s² 3p⁶ 4s² 3d¹⁰ 4p⁶ 5s² 4d¹⁰ 5p⁶ 6s¹",
      "electronegativity": "0.79",
      "meltingPoint": "28.44°C",
      "boilingPoint": "671°C",
      "density": "1.873 g/cm³",
      "discoveredBy": "Robert Bunsen, Gustav Kirchhoff",
      "discoveryYear": "1860",
      "electrons": 55,
      "protons": 55,
      "neutrons": 78
    },
    "Ba": {
      "atomicMass": "137.33",
      "category": "Alkaline earth metals",
      "electronConfig": "1s² 2s² 2p⁶ 3s² 3p⁶ 4s² 3d¹⁰ 4p⁶ 5s² 4d¹⁰ 5p⁶ 6s²",
      "electronegativity": "0.89",
      "meltingPoint": "727°C",
      "boilingPoint": "1897°C",
      "density": "3.51 g/cm³",
      "discoveredBy": "Carl Wilhelm Scheele",
      "discoveryYear": "1772",
      "electrons": 56,
      "protons": 56,
      "neutrons": 81
    },
    "La": {
      "atomicMass": "138.91",
      "category": "Lanthanides",
      "electronConfig": "1s² 2s² 2p⁶ 3s² 3p⁶ 4s² 3d¹⁰ 4p⁶ 5s² 4d¹⁰ 5p⁶ 6s² 5d¹",
      "electronegativity": "1.1",
      "meltingPoint": "920°C",
      "boilingPoint": "3464°C",
      "density": "6.162 g/cm³",
      "discoveredBy": "Carl Gustaf Mosander",
      "discoveryYear": "1839",
      "electrons": 57,
      "protons": 57,
      "neutrons": 82
    },
    "Ce": {
      "atomicMass": "140.12",
      "category": "Lanthanides",
      "electronConfig": "1s² 2s² 2p⁶ 3s² 3p⁶ 4s² 3d¹⁰ 4p⁶ 5s² 4d¹⁰ 5p⁶ 6s² 4f¹ 5d¹",
      "electronegativity": "1.12",
      "meltingPoint": "797°C",
      "boilingPoint": "3443°C",
      "density": "6.77 g/cm³",
      "discoveredBy": "Martin Heinrich Klaproth, Jöns Jakob Berzelius, Wilhelm Hisinger",
      "discoveryYear": "1803",
      "electrons": 58,
      "protons": 58,
      "neutrons": 82
    },
    "Pr": {
      "atomicMass": "140.91",
      "category": "Lanthanides",
      "electronConfig": "1s² 2s² 2p⁶ 3s² 3p⁶ 4s² 3d¹⁰ 4p⁶ 5s² 4d¹⁰ 5p⁶ 6s² 4f³",
      "electronegativity": "1.13",
      "meltingPoint": "931°C",
      "boilingPoint": "3520°C",
      "density": "6.77 g/cm³",
      "discoveredBy": "Carl Gustaf Mosander",
      "discoveryYear": "1841",
      "electrons": 59,
      "protons": 59,
      "neutrons": 82
    },
    "Nd": {
      "atomicMass": "144.24",
      "category": "Lanthanides",
      "electronConfig": "1s² 2s² 2p⁶ 3s² 3p⁶ 4s² 3d¹⁰ 4p⁶ 5s² 4d¹⁰ 5p⁶ 6s² 4f⁴",
      "electronegativity": "1.14",
      "meltingPoint": "1016°C",
      "boilingPoint": "3074°C",
      "density": "7.01 g/cm³",
      "discoveredBy": "Carl Gustaf Mosander",
      "discoveryYear": "1841",
      "electrons": 60,
      "protons": 60,
      "neutrons": 84
    },
    "Pm": {
      "atomicMass": "145.00",
      "category": "Lanthanides",
      "electronConfig": "1s² 2s² 2p⁶ 3s² 3p⁶ 4s² 3d¹⁰ 4p⁶ 5s² 4d¹⁰ 5p⁶ 6s² 4f⁵",
      "electronegativity": "1.13",
      "meltingPoint": "1042°C",
      "boilingPoint": "3000°C",
      "density": "7.26 g/cm³",
      "discoveredBy": "Jacob A. Marinsky, Lawrence E. Glendenin, Charles D. Coryell",
      "discoveryYear": "1945",
      "electrons": 61,
      "protons": 61,
      "neutrons": 84
    },
    "Sm": {
      "atomicMass": "150.36",
      "category": "Lanthanides",
      "electronConfig": "1s² 2s² 2p⁶ 3s² 3p⁶ 4s² 3d¹⁰ 4p⁶ 5s² 4d¹⁰ 5p⁶ 6s² 4f⁶",
      "electronegativity": "1.17",
      "meltingPoint": "1072°C",
      "boilingPoint": "1794°C",
      "density": "7.52 g/cm³",
      "discoveredBy": "Lecoq de Boisbaudran",
      "discoveryYear": "1879",
      "electrons": 62,
      "protons": 62,
      "neutrons": 88
    },
    "Eu": {
      "atomicMass": "151.96",
      "category": "Lanthanides",
      "electronConfig": "1s² 2s² 2p⁶ 3s² 3p⁶ 4s² 3d¹⁰ 4p⁶ 5s² 4d¹⁰ 5p⁶ 6s² 4f⁷",
      "electronegativity": "1.2",
      "meltingPoint": "822°C",
      "boilingPoint": "1529°C",
      "density": "5.24 g/cm³",
      "discoveredBy": "Eugène-Anatole Demarçay",
      "discoveryYear": "1901",
      "electrons": 63,
      "protons": 63,
      "neutrons": 89
    },
    "Gd": {
      "atomicMass": "157.25",
      "category": "Lanthanides",
      "electronConfig": "1s² 2s² 2p⁶ 3s² 3p⁶ 4s² 3d¹⁰ 4p⁶ 5s² 4d¹⁰ 5p⁶ 6s² 4f⁷ 5d¹",
      "electronegativity": "1.2",
      "meltingPoint": "1313°C",
      "boilingPoint": "3273°C",
      "density": "7.9 g/cm³",
      "discoveredBy": "Jean Charles Galissard de Marignac",
      "discoveryYear": "1880",
      "electrons": 64,
      "protons": 64,
      "neutrons": 93
    },
    "Tb": {
      "atomicMass": "158.93",
      "category": "Lanthanides",
      "electronConfig": "1s² 2s² 2p⁶ 3s² 3p⁶ 4s² 3d¹⁰ 4p⁶ 5s² 4d¹⁰ 5p⁶ 6s² 4f⁹",
      "electronegativity": "1.2",
      "meltingPoint": "1356°C",
      "boilingPoint": "3230°C",
      "density": "8.23 g/cm³",
      "discoveredBy": "Carl Gustaf Mosander",
      "discoveryYear": "1843",
      "electrons": 65,
      "protons": 65,
      "neutrons": 94
    },
    "Dy": {
      "atomicMass": "162.50",
      "category": "Lanthanides",
      "electronConfig": "1s² 2s² 2p⁶ 3s² 3p⁶ 4s² 3d¹⁰ 4p⁶ 5s² 4d¹⁰ 5p⁶ 6s² 4f¹⁰",
      "electronegativity": "1.22",
      "meltingPoint": "1412°C",
      "boilingPoint": "2567°C",
      "density": "8.55 g/cm³",
      "discoveredBy": "Lecoq de Boisbaudran",
      "discoveryYear": "1886",
      "electrons": 66,
      "protons": 66,
      "neutrons": 97
    },
    "Ho": {
      "atomicMass": "164.93",
      "category": "Lanthanides",
      "electronConfig": "1s² 2s² 2p⁶ 3s² 3p⁶ 4s² 3d¹⁰ 4p⁶ 5s² 4d¹⁰ 5p⁶ 6s² 4f¹¹",
      "electronegativity": "1.23",
      "meltingPoint": "1474°C",
      "boilingPoint": "2700°C",
      "density": "8.8 g/cm³",
      "discoveredBy": "Marc Delafontaine, Jacques-Louis Soret",
      "discoveryYear": "1878",
      "electrons": 67,
      "protons": 67,
      "neutrons": 98
    },
    "Er": {
      "atomicMass": "167.26",
      "category": "Lanthanides",
      "electronConfig": "1s² 2s² 2p⁶ 3s² 3p⁶ 4s² 3d¹⁰ 4p⁶ 5s² 4d¹⁰ 5p⁶ 6s² 4f¹²",
      "electronegativity": "1.24",
      "meltingPoint": "1529°C",
      "boilingPoint": "2868°C",
      "density": "9.07 g/cm³",
      "discoveredBy": "Carl Gustaf Mosander",
      "discoveryYear": "1843",
      "electrons": 68,
      "protons": 68,
      "neutrons": 99
    },
    "Tm": {
      "atomicMass": "168.93",
      "category": "Lanthanides",
      "electronConfig": "1s² 2s² 2p⁶ 3s² 3p⁶ 4s² 3d¹⁰ 4p⁶ 5s² 4d¹⁰ 5p⁶ 6s² 4f¹³",
      "electronegativity": "1.25",
      "meltingPoint": "1545°C",
      "boilingPoint": "1950°C",
      "density": "9.32 g/cm³",
      "discoveredBy": "Per Teodor Cleve",
      "discoveryYear": "1879",
      "electrons": 69,
      "protons": 69,
      "neutrons": 100
    },
    "Yb": {
      "atomicMass": "173.05",
      "category": "Lanthanides",
      "electronConfig": "1s² 2s² 2p⁶ 3s² 3p⁶ 4s² 3d¹⁰ 4p⁶ 5s² 4d¹⁰ 5p⁶ 6s² 4f¹⁴",
      "electronegativity": "1.1",
      "meltingPoint": "819°C",
      "boilingPoint": "1196°C",
      "density": "6.9 g/cm³",
      "discoveredBy": "Jean Charles Galissard de Marignac",
      "discoveryYear": "1878",
      "electrons": 70,
      "protons": 70,
      "neutrons": 103
    },
    "Lu": {
      "atomicMass": "174.97",
      "category": "Lanthanides",
      "electronConfig": "1s² 2s² 2p⁶ 3s² 3p⁶ 4s² 3d¹⁰ 4p⁶ 5s² 4d¹⁰ 5p⁶ 6s² 4f¹⁴ 5d¹",
      "electronegativity": "1.27",
      "meltingPoint": "1663°C",
      "boilingPoint": "3402°C",
      "density": "9.84 g/cm³",
      "discoveredBy": "Georges Urbain",
      "discoveryYear": "1907",
      "electrons": 71,
      "protons": 71,
      "neutrons": 104
    },
    "Hf": {
      "atomicMass": "178.49",
      "category": "Transition metals",
      "electronConfig": "1s² 2s² 2p⁶ 3s² 3p⁶ 4s² 3d¹⁰ 4p⁶ 5s² 4d¹⁰ 5p⁶ 6s² 4f¹⁴ 5d²",
      "electronegativity": "1.3",
      "meltingPoint": "2233°C",
      "boilingPoint": "4603°C",
      "density": "13.31 g/cm³",
      "discoveredBy": "Dirk Coster, George de Hevesy",
      "discoveryYear": "1923",
      "electrons": 72,
      "protons": 72,
      "neutrons": 106
    },
    "Ta": {
      "atomicMass": "180.95",
      "category": "Transition metals",
      "electronConfig": "1s² 2s² 2p⁶ 3s² 3p⁶ 4s² 3d¹⁰ 4p⁶ 5s² 4d¹⁰ 5p⁶ 6s² 4f¹⁴ 5d³",
      "electronegativity": "1.5",
      "meltingPoint": "3017°C",
      "boilingPoint": "5458°C",
      "density": "16.69 g/cm³",
      "discoveredBy": "Anders Gustaf Ekeberg",
      "discoveryYear": "1802",
      "electrons": 73,
      "protons": 73,
      "neutrons": 108
    },
    "W": {
      "atomicMass": "183.84",
      "category": "Transition metals",
      "electronConfig": "1s² 2s² 2p⁶ 3s² 3p⁶ 4s² 3d¹⁰ 4p⁶ 5s² 4d¹⁰ 5p⁶ 6s² 4f¹⁴ 5d⁴",
      "electronegativity": "2.36",
      "meltingPoint": "3422°C",
      "boilingPoint": "5555°C",
      "density": "19.25 g/cm³",
      "discoveredBy": "Carl Wilhelm Scheele",
      "discoveryYear": "1781",
      "electrons": 74,
      "protons": 74,
      "neutrons": 110
    },
    "Re": {
      "atomicMass": "186.21",
      "category": "Transition metals",
      "electronConfig": "1s² 2s² 2p⁶ 3s² 3p⁶ 4s² 3d¹⁰ 4p⁶ 5s² 4d¹⁰ 5p⁶ 6s² 4f¹⁴ 5d⁵",
      "electronegativity": "1.9",
      "meltingPoint": "3186°C",
      "boilingPoint": "5596°C",
      "density": "21.02 g/cm³",
      "discoveredBy": "Masataka Ogawa",
      "discoveryYear": "1908",
      "electrons": 75,
      "protons": 75,
      "neutrons": 111
    },
    "Os": {
      "atomicMass": "190.23",
      "category": "Transition metals",
      "electronConfig": "1s² 2s² 2p⁶ 3s² 3p⁶ 4s² 3d¹⁰ 4p⁶ 5s² 4d¹⁰ 5p⁶ 6s² 4f¹⁴ 5d⁶",
      "electronegativity": "2.2",
      "meltingPoint": "3033°C",
      "boilingPoint": "5012°C",
      "density": "22.61 g/cm³",
      "discoveredBy": "Smithson Tennant",
      "discoveryYear": "1803",
      "electrons": 76,
      "protons": 76,
      "neutrons": 114
    },
    "Ir": {
      "atomicMass": "192.22",
      "category": "Transition metals",
      "electronConfig": "1s² 2s² 2p⁶ 3s² 3p⁶ 4s² 3d¹⁰ 4p⁶ 5s² 4d¹⁰ 5p⁶ 6s² 4f¹⁴ 5d⁷",
      "electronegativity": "2.2",
      "meltingPoint": "2466°C",
      "boilingPoint": "4428°C",
      "density": "22.56 g/cm³",
      "discoveredBy": "Smithson Tennant",
      "discoveryYear": "1803",
      "electrons": 77,
      "protons": 77,
      "neutrons": 115
    },
    "Pt": {
      "atomicMass": "195.08",
      "category": "Transition metals",
      "electronConfig": "1s² 2s² 2p⁶ 3s² 3p⁶ 4s² 3d¹⁰ 4p⁶ 5s² 4d¹⁰ 5p⁶ 6s¹ 4f¹⁴ 5d⁹",
      "electronegativity": "2.28",
      "meltingPoint": "1768.3°C",
      "boilingPoint": "3825°C",
      "density": "21.45 g/cm³",
      "discoveredBy": "Antonio de Ulloa",
      "discoveryYear": "1735",
      "electrons": 78,
      "protons": 78,
      "neutrons": 117
    },
    "Au": {
      "atomicMass": "196.97",
      "category": "Transition metals",
      "electronConfig": "1s² 2s² 2p⁶ 3s² 3p⁶ 4s² 3d¹⁰ 4p⁶ 5s² 4d¹⁰ 5p⁶ 6s¹ 4f¹⁴ 5d¹⁰",
      "electronegativity": "2.54",
      "meltingPoint": "1064.18°C",
      "boilingPoint": "2856°C",
      "density": "19.3 g/cm³",
      "discoveredBy": "Known since ancient times",
      "discoveryYear": "Ancient",
      "electrons": 79,
      "protons": 79,
      "neutrons": 118
    },
    "Hg": {
      "atomicMass": "200.59",
      "category": "Transition metals",
      "electronConfig": "1s² 2s² 2p⁶ 3s² 3p⁶ 4s² 3d¹⁰ 4p⁶ 5s² 4d¹⁰ 5p⁶ 6s² 4f¹⁴ 5d¹⁰",
      "electronegativity": "2.0",
      "meltingPoint": "-38.83°C",
      "boilingPoint": "356.73°C",
      "density": "13.534 g/cm³",
      "discoveredBy": "Known since ancient times",
      "discoveryYear": "Ancient",
      "electrons": 80,
      "protons": 80,
      "neutrons":121
    },
    "Tl": {
      "atomicMass": "204.38",
      "category": "Post-transition metals",
      "electronConfig": "1s² 2s² 2p⁶ 3s² 3p⁶ 4s² 3d¹⁰ 4p⁶ 5s² 4d¹⁰ 5p⁶ 6s² 4f¹⁴ 5d¹⁰ 6p¹",
      "electronegativity": "1.62",
      "meltingPoint": "304°C",
      "boilingPoint": "1473°C",
      "density": "11.85 g/cm³",
      "discoveredBy": "William Crookes",
      "discoveryYear": "1861",
      "electrons": 81,
      "protons": 81,
      "neutrons": 123
    },
    "Pb": {
      "atomicMass": "207.2",
      "category": "Post-transition metals",
      "electronConfig": "1s² 2s² 2p⁶ 3s² 3p⁶ 4s² 3d¹⁰ 4p⁶ 5s² 4d¹⁰ 5p⁶ 6s² 4f¹⁴ 5d¹⁰ 6p²",
      "electronegativity": "2.33",
      "meltingPoint": "327.46°C",
      "boilingPoint": "1749°C",
      "density": "11.34 g/cm³",
      "discoveredBy": "Known since ancient times",
      "discoveryYear": "Ancient",
      "electrons": 82,
      "protons": 82,
      "neutrons": 125
    },
    "Bi": {
      "atomicMass": "208.98",
      "category": "Post-transition metals",
      "electronConfig": "1s² 2s² 2p⁶ 3s² 3p⁶ 4s² 3d¹⁰ 4p⁶ 5s² 4d¹⁰ 5p⁶ 6s² 4f¹⁴ 5d¹⁰ 6p³",
      "electronegativity": "2.02",
      "meltingPoint": "271.5°C",
      "boilingPoint": "1564°C",
      "density": "9.78 g/cm³",
      "discoveredBy": "Claude François Geoffroy",
      "discoveryYear": "1753",
      "electrons": 83,
      "protons": 83,
      "neutrons": 126
    },
    "Po": {
      "atomicMass": "209",
      "category": "Metalloids",
      "electronConfig": "1s² 2s² 2p⁶ 3s² 3p⁶ 4s² 3d¹⁰ 4p⁶ 5s² 4d¹⁰ 5p⁶ 6s² 4f¹⁴ 5d¹⁰ 6p⁴",
      "electronegativity": "2.0",
      "meltingPoint": "254°C",
      "boilingPoint": "962°C",
      "density": "9.196 g/cm³",
      "discoveredBy": "Marie Curie",
      "discoveryYear": "1898",
      "electrons": 84,
      "protons": 84,
      "neutrons": 125
    },
    "At": {
      "atomicMass": "210",
      "category": "Halogens",
      "electronConfig": "1s² 2s² 2p⁶ 3s² 3p⁶ 4s² 3d¹⁰ 4p⁶ 5s² 4d¹⁰ 5p⁶ 6s² 4f¹⁴ 5d¹⁰ 6p⁵",
      "electronegativity": "2.2",
      "meltingPoint": "302°C",
      "boilingPoint": "337°C",
      "density": "7 g/cm³ (estimated)",
      "discoveredBy": "Dale R. Corson, Kenneth Ross MacKenzie, Emilio Segrè",
      "discoveryYear": "1940",
      "electrons": 85,
      "protons": 85,
      "neutrons": 125
    },
    "Rn": {
      "atomicMass": "222",
      "category": "Noble gases",
      "electronConfig": "1s² 2s² 2p⁶ 3s² 3p⁶ 4s² 3d¹⁰ 4p⁶ 5s² 4d¹⁰ 5p⁶ 6s² 4f¹⁴ 5d¹⁰ 6p⁶",
      "electronegativity": "2.2",
      "meltingPoint": "-71°C",
      "boilingPoint": "-61.7°C",
      "density": "9.73 g/cm³ (gas at STP)",
      "discoveredBy": "Friedrich Ernst Dorn",
      "discoveryYear": "1900",
      "electrons": 86,
      "protons": 86,
      "neutrons": 136
    },
    "Fr": {
      "atomicMass": "223",
      "category": "Alkali metals",
      "electronConfig": "1s² 2s² 2p⁶ 3s² 3p⁶ 4s² 3d¹⁰ 4p⁶ 5s² 4d¹⁰ 5p⁶ 6s² 4f¹⁴ 5d¹⁰ 6p⁶ 7s¹",
      "electronegativity": "0.7",
      "meltingPoint": "27°C",
      "boilingPoint": "677°C",
      "density": "1.87 g/cm³",
      "discoveredBy": "Marguerite Perey",
      "discoveryYear": "1939",
      "electrons": 87,
      "protons": 87,
      "neutrons": 136
    },
    "Ra": {
      "atomicMass": "226",
      "category": "Alkaline earth metals",
      "electronConfig": "1s² 2s² 2p⁶ 3s² 3p⁶ 4s² 3d¹⁰ 4p⁶ 5s² 4d¹⁰ 5p⁶ 6s² 4f¹⁴ 5d¹⁰ 6p⁶ 7s²",
      "electronegativity": "0.9",
      "meltingPoint": "700°C",
      "boilingPoint": "1737°C",
      "density": "5.5 g/cm³",
      "discoveredBy": "Marie Curie, Pierre Curie",
      "discoveryYear": "1898",
      "electrons": 88,
      "protons": 88,
      "neutrons": 138
    },
    "Ac": {
      "atomicMass": "227",
      "category": "Actinides",
      "electronConfig": "1s² 2s² 2p⁶ 3s² 3p⁶ 4s² 3d¹⁰ 4p⁶ 5s² 4d¹⁰ 5p⁶ 6s² 4f¹⁴ 5d¹⁰ 6p⁶ 7s² 6d¹",
      "electronegativity": "1.1",
      "meltingPoint": "1050°C",
      "boilingPoint": "3200°C",
      "density": "10.07 g/cm³",
      "discoveredBy": "André-Louis Debierne",
      "discoveryYear": "1899",
      "electrons": 89,
      "protons": 89,
      "neutrons": 138
    },
    "Th": {
      "atomicMass": "232.04",
      "category": "Actinides",
      "electronConfig": "1s² 2s² 2p⁶ 3s² 3p⁶ 4s² 3d¹⁰ 4p⁶ 5s² 4d¹⁰ 5p⁶ 6s² 4f¹⁴ 5d¹⁰ 6p⁶ 7s² 6d²",
      "electronegativity": "1.3",
      "meltingPoint": "1750°C",
      "boilingPoint": "4788°C",
      "density": "11.72 g/cm³",
      "discoveredBy": "Jöns Jakob Berzelius",
      "discoveryYear": "1828",
      "electrons": 90,
      "protons": 90,
      "neutrons": 142
    },
        "Pa": {
      "atomicMass": "231.04",
      "category": "Actinides",
      "electronConfig": "[Rn] 5f² 6d¹ 7s²",
      "electronegativity": "1.5",
      "meltingPoint": "1572°C",
      "boilingPoint": "4000°C (estimated)",
      "density": "15.37 g/cm³",
      "discoveredBy": "Kasimir Fajans, Oswald Helmuth Göhring",
      "discoveryYear": "1913",
      "electrons": 91,
      "protons": 91,
      "neutrons": 140
    },
    "U": {
      "atomicMass": "238.03",
      "category": "Actinides",
      "electronConfig": "[Rn] 5f³ 6d¹ 7s²",
      "electronegativity": "1.38",
      "meltingPoint": "1132°C",
      "boilingPoint": "4131°C",
      "density": "19.05 g/cm³",
      "discoveredBy": "Martin Heinrich Klaproth",
      "discoveryYear": "1789",
      "electrons": 92,
      "protons": 92,
      "neutrons": 146
    },
    "Np": {
      "atomicMass": "237",
      "category": "Actinides",
      "electronConfig": "[Rn] 5f⁴ 6d¹ 7s²",
      "electronegativity": "1.36",
      "meltingPoint": "644°C",
      "boilingPoint": "3902°C (estimated)",
      "density": "20.45 g/cm³",
      "discoveredBy": "Edwin McMillan, Philip H. Abelson",
      "discoveryYear": "1940",
      "electrons": 93,
      "protons": 93,
      "neutrons": 144
    },
    "Pu": {
      "atomicMass": "244",
      "category": "Actinides",
      "electronConfig": "[Rn] 5f⁶ 7s²",
      "electronegativity": "1.28",
      "meltingPoint": "639.4°C",
      "boilingPoint": "3228°C",
      "density": "19.84 g/cm³",
      "discoveredBy": "Glenn T. Seaborg, Arthur Wahl, Joseph W. Kennedy, Edwin McMillan",
      "discoveryYear": "1940",
      "electrons": 94,
      "protons": 94,
      "neutrons": 150
    },
    "Am": {
      "atomicMass": "243",
      "category": "Actinides",
      "electronConfig": "[Rn] 5f⁷ 7s²",
      "electronegativity": "1.13",
      "meltingPoint": "1176°C",
      "boilingPoint": "2607°C (estimated)",
      "density": "13.69 g/cm³",
      "discoveredBy": "Glenn T. Seaborg, Ralph A. James, Leon O. Morgan, Albert Ghiorso",
      "discoveryYear": "1944",
      "electrons": 95,
      "protons": 95,
      "neutrons": 148
    },
    "Cm": {
      "atomicMass": "247",
      "category": "Actinides",
      "electronConfig": "[Rn] 5f⁷ 6d¹ 7s²",
      "electronegativity": "1.28",
      "meltingPoint": "1340°C",
      "boilingPoint": "3110°C (estimated)",
      "density": "13.51 g/cm³",
      "discoveredBy": "Glenn T. Seaborg, Ralph A. James, Albert Ghiorso",
      "discoveryYear": "1944",
      "electrons": 96,
      "protons": 96,
      "neutrons": 151
    },
    "Bk": {
      "atomicMass": "247",
      "category": "Actinides",
      "electronConfig": "[Rn] 5f⁹ 7s²",
      "electronegativity": "1.3",
      "meltingPoint": "986°C",
      "boilingPoint": "2627°C (estimated)",
      "density": "14.79 g/cm³",
      "discoveredBy": "Glenn T. Seaborg, Stanley G. Thompson, Albert Ghiorso",
      "discoveryYear": "1949",
      "electrons": 97,
      "protons": 97,
      "neutrons": 150
    },
    "Cf": {
      "atomicMass": "251",
      "category": "Actinides",
      "electronConfig": "[Rn] 5f¹⁰ 7s²",
      "electronegativity": "1.3",
      "meltingPoint": "900°C",
      "boilingPoint": "1470°C (estimated)",
      "density": "15.1 g/cm³",
      "discoveredBy": "Glenn T. Seaborg, Stanley G. Thompson, Albert Ghiorso",
      "discoveryYear": "1950",
      "electrons": 98,
      "protons": 98,
      "neutrons": 153
    },
    "Es": {
      "atomicMass": "252",
      "category": "Actinides",
      "electronConfig": "[Rn] 5f¹¹ 7s²",
      "electronegativity": "1.3",
      "meltingPoint": "860°C",
      "boilingPoint": "Unknown",
      "density": "8.84 g/cm³ (estimated)",
      "discoveredBy": "Albert Ghiorso, Glenn T. Seaborg, Ralph A. James",
      "discoveryYear": "1952",
      "electrons": 99,
      "protons": 99,
      "neutrons": 153
    },
    "Fm": {
      "atomicMass": "257",
      "category": "Actinides",
      "electronConfig": "[Rn] 5f¹² 7s²",
      "electronegativity": "1.3",
      "meltingPoint": "1527°C",
      "boilingPoint": "Unknown",
      "density": "9.7 g/cm³ (estimated)",
      "discoveredBy": "Albert Ghiorso, Glenn T. Seaborg, Ralph A. James",
      "discoveryYear": "1952",
      "electrons": 100,
      "protons": 100,
      "neutrons": 157
    },
    "Md": {
      "atomicMass": "258",
      "category": "Actinides",
      "electronConfig": "[Rn] 5f¹³ 7s²",
      "electronegativity": "1.3",
      "meltingPoint": "827°C",
      "boilingPoint": "Unknown",
      "density": "10.3 g/cm³ (estimated)",
      "discoveredBy": "Albert Ghiorso, Glenn T. Seaborg, Bernard G. Harvey, Gregory R. Choppin, Stanley G. Thompson",
      "discoveryYear": "1955",
      "electrons": 101,
      "protons": 101,
      "neutrons": 157
    },
    "No": {
      "atomicMass": "259",
      "category": "Actinides",
      "electronConfig": "[Rn] 5f¹⁴ 7s²",
      "electronegativity": "1.3",
      "meltingPoint": "827°C",
      "boilingPoint": "Unknown",
      "density": "9.9 g/cm³ (estimated)",
      "discoveredBy": "Albert Ghiorso, Glenn T. Seaborg, Torbørn Sikkeland, John R. Walton",
      "discoveryYear": "1958",
      "electrons": 102,
      "protons": 102,
      "neutrons": 157
    },
    "Lr": {
      "atomicMass": "266",
      "category": "Actinides",
      "electronConfig": "[Rn] 5f¹⁴ 6d¹ 7s² (predicted)",
      "electronegativity": "1.3",
      "meltingPoint": "1627°C (estimated)",
      "boilingPoint": "Unknown",
      "density": "Unknown",
      "discoveredBy": "Albert Ghiorso, Torbjørn Sikkeland, Almon E. Larsh, Robert M. Latimer",
      "discoveryYear": "1961",
      "electrons": 103,
      "protons": 103,
      "neutrons": 163
    },
    "Rf": {
      "atomicMass": "267",
      "category": "Transition metals",
      "electronConfig": "[Rn] 5f¹⁴ 6d² 7s² (predicted)",
      "electronegativity": "Unknown",
      "meltingPoint": "2100°C (estimated)",
      "boilingPoint": "Unknown",
      "density": "Unknown",
      "discoveredBy": "Joint Institute for Nuclear Research (Russia)",
      "discoveryYear": "1964",
      "electrons": 104,
      "protons": 104,
      "neutrons": 163
    },
    "Db": {
      "atomicMass": "268",
      "category": "Transition metals",
      "electronConfig": "[Rn] 5f¹⁴ 6d³ 7s² (predicted)",
      "electronegativity": "Unknown",
      "meltingPoint": "Unknown",
      "boilingPoint": "Unknown",
      "density": "Unknown",
      "discoveredBy": "Joint Institute for Nuclear Research (Russia)",
      "discoveryYear": "1967",
      "electrons": 105,
      "protons": 105,
      "neutrons": 163
    },
    "Sg": {
      "atomicMass": "269",
      "category": "Transition metals",
      "electronConfig": "[Rn] 5f¹⁴ 6d⁴ 7s² (predicted)",
      "electronegativity": "Unknown",
      "meltingPoint": "Unknown",
      "boilingPoint": "Unknown",
      "density": "Unknown",
      "discoveredBy": "Joint Institute for Nuclear Research (Russia)",
      "discoveryYear": "1974",
      "electrons": 106,
      "protons": 106,
      "neutrons": 163
    },
    "Bh": {
      "atomicMass": "270",
      "category": "Transition metals",
      "electronConfig": "[Rn] 5f¹⁴ 6d⁵ 7s² (predicted)",
      "electronegativity": "Unknown",
      "meltingPoint": "Unknown",
      "boilingPoint": "Unknown",
      "density": "Unknown",
      "discoveredBy": "GSI Helmholtz Centre (Germany)",
      "discoveryYear": "1981",
      "electrons": 107,
      "protons": 107,
      "neutrons": 163
    },
    "Hs": {
      "atomicMass": "269",
      "category": "Transition metals",
      "electronConfig": "[Rn] 5f¹⁴ 6d⁶ 7s² (predicted)",
      "electronegativity": "Unknown",
      "meltingPoint": "Unknown",
      "boilingPoint": "Unknown",
      "density": "Unknown",
      "discoveredBy": "GSI Helmholtz Centre (Germany)",
      "discoveryYear": "1984",
      "electrons": 108,
      "protons": 108,
      "neutrons": 161
    },
    "Mt": {
      "atomicMass": "278",
      "category": "Transition metals",
      "electronConfig": "[Rn] 5f¹⁴ 6d⁷ 7s² (predicted)",
      "electronegativity": "Unknown",
      "meltingPoint": "Unknown",
      "boilingPoint": "Unknown",
      "density": "Unknown",
      "discoveredBy": "GSI Helmholtz Centre (Germany)",
      "discoveryYear": "1982",
      "electrons": 109,
      "protons": 109,
      "neutrons": 169
    },
    "Ds": {
      "atomicMass": "281",
      "category": "Transition metals",
      "electronConfig": "[Rn] 5f¹⁴ 6d⁹ 7s¹ (predicted)",
      "electronegativity": "Unknown",
      "meltingPoint": "Unknown",
      "boilingPoint": "Unknown",
      "density": "Unknown",
      "discoveredBy": "GSI Helmholtz Centre (Germany)",
      "discoveryYear": "1994",
      "electrons": 110,
      "protons": 110,
      "neutrons": 171
    },
        "Rg": {
      "atomicMass": "282",
      "category": "Transition metals",
      "electronConfig": "[Rn] 5f¹⁴ 6d¹⁰ 7s¹ (predicted)",
      "electronegativity": "Unknown",
      "meltingPoint": "Unknown",
      "boilingPoint": "Unknown",
      "density": "Unknown",
      "discoveredBy": "GSI Helmholtz Centre (Germany)",
      "discoveryYear": "1994",
      "electrons": 111,
      "protons": 111,
      "neutrons": 171
    },
    "Cn": {
      "atomicMass": "285",
      "category": "Transition metals",
      "electronConfig": "[Rn] 5f¹⁴ 6d¹⁰ 7s² (predicted)",
      "electronegativity": "Unknown",
      "meltingPoint": "Unknown",
      "boilingPoint": "Unknown",
      "density": "Unknown",
      "discoveredBy": "GSI Helmholtz Centre (Germany)",
      "discoveryYear": "1996",
      "electrons": 112,
      "protons": 112,
      "neutrons": 173
    },
    "Nh": {
      "atomicMass": "286",
      "category": "Post-transition metals",
      "electronConfig": "[Rn] 5f¹⁴ 6d¹⁰ 7s² 7p¹ (predicted)",
      "electronegativity": "Unknown",
      "meltingPoint": "Unknown",
      "boilingPoint": "Unknown",
      "density": "Unknown",
      "discoveredBy": "Joint Institute for Nuclear Research (Russia) & Lawrence Livermore National Lab (USA)",
      "discoveryYear": "2003",
      "electrons": 113,
      "protons": 113,
      "neutrons": 173
    },
    "Fl": {
      "atomicMass": "289",
      "category": "Post-transition metals",
      "electronConfig": "[Rn] 5f¹⁴ 6d¹⁰ 7s² 7p² (predicted)",
      "electronegativity": "Unknown",
      "meltingPoint": "Unknown",
      "boilingPoint": "Unknown",
      "density": "Unknown",
      "discoveredBy": "Joint Institute for Nuclear Research (Russia) & Lawrence Livermore National Lab (USA)",
      "discoveryYear": "1998",
      "electrons": 114,
      "protons": 114,
      "neutrons": 175
    },
    "Mc": {
      "atomicMass": "290",
      "category": "Post-transition metals",
      "electronConfig": "[Rn] 5f¹⁴ 6d¹⁰ 7s² 7p³ (predicted)",
      "electronegativity": "Unknown",
      "meltingPoint": "Unknown",
      "boilingPoint": "Unknown",
      "density": "Unknown",
      "discoveredBy": "Joint Institute for Nuclear Research (Russia) & Lawrence Livermore National Lab (USA)",
      "discoveryYear": "2003",
      "electrons": 115,
      "protons": 115,
      "neutrons": 175
    },
    "Lv": {
      "atomicMass": "293",
      "category": "Post-transition metals",
      "electronConfig": "[Rn] 5f¹⁴ 6d¹⁰ 7s² 7p⁴ (predicted)",
      "electronegativity": "Unknown",
      "meltingPoint": "Unknown",
      "boilingPoint": "Unknown",
      "density": "Unknown",
      "discoveredBy": "Joint Institute for Nuclear Research (Russia) & Lawrence Livermore National Lab (USA)",
      "discoveryYear": "2000",
      "electrons": 116,
      "protons": 116,
      "neutrons": 177
    },
    "Ts": {
      "atomicMass": "294",
      "category": "Halogens",
      "electronConfig": "[Rn] 5f¹⁴ 6d¹⁰ 7s² 7p⁵ (predicted)",
      "electronegativity": "Unknown",
      "meltingPoint": "Unknown",
      "boilingPoint": "Unknown",
      "density": "Unknown",
      "discoveredBy": "Joint Institute for Nuclear Research (Russia) & Lawrence Livermore National Lab (USA)",
      "discoveryYear": "2010",
      "electrons": 117,
      "protons": 117,
      "neutrons": 177
    },
    "Og": {
      "atomicMass": "294",
      "category": "Noble gases",
      "electronConfig": "[Rn] 5f¹⁴ 6d¹⁰ 7s² 7p⁶ (predicted)",
      "electronegativity": "Unknown",
      "meltingPoint": "Unknown",
      "boilingPoint": "Unknown",
      "density": "Unknown",
      "discoveredBy": "Joint Institute for Nuclear Research (Russia) & Lawrence Livermore National Lab (USA)",
      "discoveryYear": "2002",
      "electrons": 118,
      "protons": 118,
      "neutrons": 176
    },
  };

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 15),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Map<String, dynamic> get elementInfo {
    return _elementData[widget.symbol] ?? {
      'atomicMass': 'Unknown',
      'category': 'Unknown',
      'electronConfig': 'Unknown',
      'electronegativity': 'Unknown',
      'meltingPoint': 'Unknown',
      'boilingPoint': 'Unknown',
      'density': 'Unknown',
      'discoveredBy': 'Unknown',
      'discoveryYear': 'Unknown',
      'electrons': int.tryParse(widget.atomicNumber) ?? 1,
      'protons': int.tryParse(widget.atomicNumber) ?? 1,
      'neutrons': (int.tryParse(widget.atomicNumber) ?? 1) - 1,
    };
  }

  @override
  Widget build(BuildContext context) {
    final int electrons = elementInfo['electrons'];

    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.name} (${widget.symbol})'),
        backgroundColor: Colors.blueGrey[800],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 10),
              Card(
                elevation: 4,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      Text(
                        widget.symbol,
                        style: const TextStyle(
                          fontSize: 48,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        widget.name,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Text(
                        'Atomic Number: ${widget.atomicNumber}',
                        style: const TextStyle(
                          fontSize: 18,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Bohr Model',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              SizedBox(
                height: 300,
                child: AnimatedBuilder(
                  animation: _controller,
                  builder: (_, __) {
                    return CustomPaint(
                      painter: BohrModelPainter(
                        electrons: electrons,
                        animationValue: _controller.value,
                      ),
                      size: const Size(300, 300),
                    );
                  },
                ),
              ),
              const SizedBox(height: 20),
              Card(
                elevation: 3,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Properties',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 10),
                      _buildPropertyRow('Category', elementInfo['category']),
                      _buildPropertyRow('Atomic Mass', elementInfo['atomicMass']),
                      _buildPropertyRow('Electron Configuration', elementInfo['electronConfig']),
                      _buildPropertyRow('Electronegativity', elementInfo['electronegativity']),
                      _buildPropertyRow('Melting Point', elementInfo['meltingPoint']),
                      _buildPropertyRow('Boiling Point', elementInfo['boilingPoint']),
                      _buildPropertyRow('Density', elementInfo['density']),
                      _buildPropertyRow('Discovered By', elementInfo['discoveredBy']),
                      _buildPropertyRow('Discovery Year', elementInfo['discoveryYear']),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Card(
                elevation: 3,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Atomic Structure',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 10),
                      _buildPropertyRow('Protons', elementInfo['protons'].toString()),
                      _buildPropertyRow('Neutrons', elementInfo['neutrons'].toString()),
                      _buildPropertyRow('Electrons', elementInfo['electrons'].toString()),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPropertyRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 150,
            child: Text(
              '$label:',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Expanded(
            child: Text(value),
          ),
        ],
      ),
    );
  }
}

class BohrModelPainter extends CustomPainter {
  final int electrons;
  final double animationValue;

  BohrModelPainter({
    required this.electrons,
    required this.animationValue,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final maxShells = _calculateShells(electrons);

    final nucleusPaint = Paint()
      ..color = Colors.red
      ..style = PaintingStyle.fill;

    final shellPaint = Paint()
      ..color = Colors.grey
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    final electronPaint = Paint()
      ..color = Colors.blue
      ..style = PaintingStyle.fill;

    canvas.drawCircle(center, 15, nucleusPaint);

    int remainingElectrons = electrons;
    for (int shell = 1; shell <= maxShells; shell++) {
      final shellRadius = 25.0 + (shell * 30.0);
      canvas.drawCircle(center, shellRadius, shellPaint);

      int electronsInShell = _electronsInShell(shell);
      if (electronsInShell > remainingElectrons) {
        electronsInShell = remainingElectrons;
      }
      remainingElectrons -= electronsInShell;

      if (electronsInShell > 0) {
        _drawElectronsOnShell(canvas, center, shellRadius, electronsInShell, electronPaint, shell);
      }

      if (remainingElectrons <= 0) break;
    }
  }

  void _drawElectronsOnShell(Canvas canvas, Offset center, double radius, int count, Paint paint, int shellNumber) {
    final double angleStep = 2 * math.pi / count;
    final double speedFactor = 1.0 / shellNumber;

    for (int i = 0; i < count; i++) {
      final angle = (i * angleStep) + (animationValue * 2 * math.pi * speedFactor);
      final x = center.dx + radius * math.cos(angle);
      final y = center.dy + radius * math.sin(angle);
      canvas.drawCircle(Offset(x, y), 6, paint);
    }
  }

  int _calculateShells(int electronCount) {
    int shells = 1;
    int electrons = 0;

    while (electrons < electronCount) {
      electrons += _electronsInShell(shells);
      if (electrons >= electronCount) break;
      shells++;
    }

    return shells;
  }

  int _electronsInShell(int shellNumber) {
    return 2 * shellNumber * shellNumber;
  }

  @override
  bool shouldRepaint(BohrModelPainter oldDelegate) {
    return oldDelegate.animationValue != animationValue ||
        oldDelegate.electrons != electrons;
  }
}
