# coding: utf-8
require 'dxruby'

### ■キャッシュの管理クラス■ ###
module Cache
  
  # ビットマップの読み込み
  def self.load_image(path)
    @cache ||= {}
    if valid?(path)
      normal_image(path)      
    else
      empty_image(path)
    end
  end
  
  # パスが有効か？
  def self.valid?(path)
    !path.empty? && !File.extname(path).empty?  
  end
  
  # 空のビットマップを作成
  def self.empty_image(path)
    @cache[path] = Image.new(32, 32) unless include?(path)
    @cache[path]
  end

  # 通常のビットマップを作成／取得
  def self.normal_image(path)
    @cache[path] = Image.load(path) unless include?(path)
    @cache[path]
  end
  
  # キャッシュ存在チェック
  def self.include?(key)
    @cache[key] && !@cache[key].disposed?
  end

  # キャッシュのクリア
  def self.clear
    @cache ||= {}
    @cache.clear
    GC.start
  end
  
end




### ■データ管理用モジュール■ ###

require 'zlib'

module DataManager 
  
  # 初期化
  def self.init
  end
  
  # データベースの読み込み
  def self.load_database
  end
  
  # データベースの保存
  def self.save_database
  end
  
  # データベースの修復
  def self.repair_database
  end
  
  # 修復
  def self.repair(database)
    database.each do |item| item.repair end
  end
  
  # ゲームオブジェクトの作成
  def self.create_game_objects

  end
  
  #  編集データの読み込み
  def self.load_data(path)
    Zlib::GzipReader.open(path) do |f|
      return Marshal.load(f.read)
    end
  end 
  
  #  編集データの書き込み
  def self.save_data(data ,path)
    Zlib::GzipWriter.open(path) do |f|
      f.write(Marshal.dump(data))
    end
  end   
end




### ■ゲームデータのエディット用モジュール■ ###
module GameDataBase

  # インスタンスが定義されているか？
  def defined_instance?(value)
    return false if instance_variable_get(value).nil?
    return self.class.method_defined?(value.sub("@",""))
  end

  # データの修復
  def repair
    new_object = self.class.new
    # 初期値に存在しないインスタンスを削除する
    (instance_variables - new_object.instance_variables).each{|v|
      remove_instance_variable(v)}
    # 初期値に存在しているが定義されていないインスタンスを追加
    (new_object.instance_variables - instance_variables).each{|v|
      instance_variable_set(v, new_object.instance_variable_get(v))}
  end
  
  # データの初期化
  def init_instance
    new_object = self.class.new
    (new_object.instance_variables).each{|v|
      instance_variable_set(v, new_object.instance_variable_get(v))}
  end
    
end




### ■ゲームデータのスーパークラス■ ###
module Game
  class DataBase
    
    # Mix-In
    include GameDataBase

    # 公開インスタンス
    attr_accessor :name
    attr_accessor :id
    attr_accessor :no
    attr_accessor :discription
    attr_accessor :protect
    attr_reader   :header
    
    # 初期化
    def initialize
      @id       = 0
      @no       = 0
      @name     = ""
      @discription = ""
      @protect = false
      @header  = false
    end
    
    # ヘッダーデータとして設定
    def header
      @id     = 0
      @no     = 0
      @name     = "なし"
      @discription = ""
      @protect = true
      @header = true
      self
    end
    
    # ヘッダーデータか？
    def header?
      @header
    end
    
    # ストリングスに変換する
    def to_s
      sprintf("%03d:%03d:%s",@no, @id, @name)
    end
    
    # データベースの作成
    def self.create_database
      [self.new.header, self.new]
    end  
    
  end
end




### 乱数テーブルのクラス ###
module RandTable
  
  # 乱数列を生成
  def self.random_numbers(min,max)
    numbers = []
    for number in min..max
      numbers.push(number)
    end
    random = []
    loop do
      pos = rand(numbers.size)
      random.push(numbers[pos])
      numbers.delete_at pos
      break if numbers.empty?
    end
    DataManager.save_data(random, "./Data/EffectRand.dat")
  end
    
  # 乱数の初期化
  def init_rand
    @rand_flag  = false
    @rand_index = 0
    @rand_coefficient = 1
  end

  # 乱数を返す
  def erand(max = 0)
    # 要素が0以下の場合は必ず0を返す
    return 0 if max <= 0
    # 組み込みの乱数を使う
    return rand(max) if @rand_flag
    # 乱数表から乱数を読み込む
    @rand_index = (@rand_index +  @rand_coefficient) % @@rand_max
    return (@@rand_table[@rand_index] * max) / @@rand_max       
  end
    
  ### クラス変数
  @@rand_table = [184, 1555, 1281, 268, 538, 564, 182, 124, 1297, 1819, 424, 1544, 1589, 569, 406, 873, 1759, 1119, 1013, 324, 482, 1551,
  1883, 1781, 1995, 1788, 792, 1729, 1943, 620, 791, 1048, 1060, 588, 517, 380, 1961, 216, 6, 1996, 1583, 1934, 1256, 100, 318, 1320, 508,
  1291, 494, 892, 731, 842, 272, 1850, 929, 811, 738, 419, 667, 266, 817, 2013, 1404, 1123, 1624, 1764, 470, 415, 1517, 1476, 413, 1247, 1815,
  1699, 1574, 331, 402, 96, 347, 1089, 2003, 1746, 511, 1116, 1706, 120, 1190, 1913, 297, 1909, 682, 707, 1717, 77, 1265, 1096, 1569, 1775,
  1587, 1647, 91, 1373, 1608, 1690, 1311, 1163, 16, 317, 1122, 1539, 1192, 680, 1740, 404, 1802, 1259, 1328, 59, 27, 772, 260, 1892, 1842,
  1363, 865, 1677, 1531, 746, 459, 1868, 901, 1681, 368, 48, 1084, 743, 992, 1888, 1173, 1136, 1278, 469, 105, 243, 1049, 1527, 1502, 781,
  700, 1601, 303, 136, 107, 1576, 1143, 2022, 212, 455, 1925, 1441, 993, 1712, 295, 814, 275, 1239, 398, 356, 1864, 897, 2014, 516, 340, 472,
  1248, 826, 1105, 1309, 1138, 788, 1318, 140, 336, 148, 1780, 1046, 258, 1556, 1718, 749, 590, 1611, 1267, 714, 1485, 543, 189, 1217, 141,
  845, 820, 1722, 1520, 108, 1948, 2036, 605, 393, 711, 1010, 99, 878, 1686, 782, 176, 1385, 651, 425, 1424, 54, 1599, 1632, 1905, 739, 1716,
  612, 1773, 757, 1127, 210, 2015, 1194, 1997, 1837, 1958, 1513, 717, 1232, 1693, 1266, 1285, 1510, 355, 1488, 211, 1762, 1349, 1901, 68, 81,
  1076, 1002, 1434, 1967, 1672, 1793, 1129, 1922, 666, 1070, 171, 1044, 436, 1204, 1272, 256, 417, 1494, 218, 1072, 196, 1493, 1191, 427, 1459,
  1329, 1284, 367, 202, 1953, 980, 1808, 1858, 1032, 71, 681, 627, 2016, 1634, 1336, 15, 57, 125, 8, 1454, 1561, 1904, 956, 95, 563, 761, 1700,
  911, 1653, 1327, 1874, 1155, 121, 139, 309, 1455, 1524, 933, 1900, 1831, 916, 1172, 1966, 1519, 194, 1701, 341, 34, 1478, 304, 55, 1115, 29,
  790, 1547, 665, 2007, 1726, 1689, 1737, 674, 633, 1356, 1277, 647, 1588, 1549, 465, 2025, 390, 1384, 1678, 1886, 1743, 1117, 2029, 888, 1222,
  652, 1112, 524, 1458, 1933, 1479, 1426, 1087, 558, 769, 1725, 629, 727, 1879, 971, 1609, 1443, 691, 542, 802, 683, 1326, 798, 512, 1645, 1562,
  1682, 655, 416, 293, 1139, 1114, 339, 411, 663, 104, 1974, 898, 585, 862, 1452, 400, 133, 259, 396, 830, 1081, 440, 853, 1754, 431, 843, 1099,
  1906, 240, 279, 592, 1950, 1804, 80, 965, 464, 1094, 1357, 1446, 1229, 540, 632, 2042, 450, 1540, 581, 1304, 606, 1593, 884, 290, 684, 53,
  668, 199, 1656, 1627, 609, 1782, 1976, 1086, 1605, 2020, 1597, 1414, 1674, 1825, 1669, 747, 1896, 238, 679, 595, 805, 1982, 568, 1941, 1226, 
  1820, 1273, 403, 38, 1503, 905, 1235, 553, 1501, 137, 1210, 986, 1489, 1435, 1838, 360, 1872, 572, 2017, 1789, 1931, 395, 982, 1183, 1343, 1003,
  1482, 1202, 282, 903, 1240, 1254, 1522, 1917, 541, 106, 1130, 1097, 1237, 69, 70, 1571, 1949, 756, 1564, 1841, 1975, 28, 47, 1362, 192, 263,
  1151, 187, 1101, 1024, 906, 1372, 561, 1100, 186, 190, 1651, 1371, 1636, 88, 822, 546, 67, 1325, 306, 1330, 1280, 1679, 1449, 1984, 735, 578,
  945, 110, 861, 489, 1056, 1688, 1022, 1355, 1106, 721, 895, 922, 997, 1649, 825, 24, 1030, 2050, 270, 662, 60, 221, 589, 708, 1243, 1807, 1919,
  441, 1052, 603, 61, 1039, 478, 1559, 774, 248, 1203, 660, 1402, 705, 1918, 154, 1970, 1436, 550, 1655, 1668, 675, 1741, 1537, 904, 1484, 1148,
  332, 961, 1709, 1367, 1575, 503, 1108, 370, 46, 1053, 1207, 481, 580, 1772, 1902, 1845, 2012, 1146, 177, 1733, 1131, 1619, 72, 1466, 188, 162,
  1848, 62, 1885, 165, 37, 1661, 1140, 1615, 1324, 767, 1552, 531, 1083, 159, 1702, 1897, 405, 719, 128, 1525, 715, 1530, 586, 1704, 1332, 920,
  484, 5, 519, 1043, 1710, 910, 131, 1038, 844, 1857, 1536, 1411, 935, 1058, 1442, 1276, 857, 1783, 1188, 1946, 56, 1420, 1724, 1810, 809, 1451,
  597, 446, 696, 1416, 1450, 315, 274, 1391, 656, 2001, 1907, 1360, 2034, 1964, 573, 1951, 621, 11, 1646, 1553, 1405, 463, 1534, 1422, 79, 1742,
  1585, 1566, 1691, 1545, 76, 292, 942, 1694, 1464, 1784, 2019, 689, 952, 305, 1867, 985, 1393, 939, 198, 114, 1935, 181, 1707, 770, 375, 1334,
  868, 1077, 1999, 23, 359, 1803, 799, 1306, 837, 998, 1579, 1770, 1293, 514, 1786, 796, 382, 206, 1774, 401, 967, 83, 1957, 858, 1914, 1572, 1347,
  337, 1408, 1196, 109, 320, 701, 902, 75, 635, 378, 497, 2027, 687, 944, 1025, 860, 1085, 1448, 1118, 948, 1603, 775, 537, 44, 1110, 78, 536,
  43, 1528, 372, 1518, 2021, 1220, 2000, 810, 1960, 599, 1971, 960, 432, 593, 1294, 713, 191, 14, 1684, 87, 1288, 1227, 659, 937, 917, 94, 951,
  1473, 280, 695, 732, 764, 228, 1586, 418, 144, 636, 138, 1988, 10, 1723, 1853, 1258, 813, 1797, 677, 912, 641, 1993, 409, 1983, 1296, 657, 1863,
  894, 1233, 1834, 1171, 807, 1828, 1351, 510, 1189, 103, 931, 1161, 1168, 1121, 1295, 779, 244, 1392, 818, 1465, 958, 1787, 1578, 644, 640, 978,
  51, 2049, 496, 223, 1208, 397, 771, 1617, 475, 145, 25, 1533, 1496, 281, 763, 428, 498, 513, 429, 381, 1144, 1821, 1554, 1180, 1133, 175, 1212,
  1675, 1417, 1869, 1697, 661, 533, 990, 926, 394, 694, 1882, 1302, 474, 698, 870, 1027, 1800, 532, 1063, 616, 611, 1319, 1785, 1394, 1231, 1290,
  1714, 257, 423, 1264, 1042, 412, 1004, 457, 1236, 1499, 1135, 653, 1822, 492, 1876, 328, 1641, 1938, 392, 1732, 947, 840, 1952, 784, 1257, 1542,
  957, 1915, 326, 1487, 1147, 1830, 1616, 1483, 1643, 1035, 522, 284, 704, 815, 964, 453, 289, 547, 1199, 1721, 170, 458, 670, 117, 4, 1973, 1095,
  1062, 1508, 1889, 1286, 2011, 760, 648, 1731, 1005, 1963, 250, 1630, 678, 1312, 220, 1471, 1811, 941, 1238, 877, 473, 924, 722, 32, 1428, 1962,
  974, 92, 520, 1977, 495, 222, 936, 1676, 129, 422, 975, 1079, 1246, 52, 1708, 995, 1756, 1491, 515, 1182, 9, 20, 637, 1317, 151, 1241, 1017, 30,
  848, 1758, 780, 1437, 602, 576, 1050, 1816, 1315, 2018, 369, 600, 1750, 2031, 1213, 1959, 1104, 852, 548, 1461, 1377, 706, 490, 1303, 1908, 1456,
  325, 1403, 1397, 288, 1849, 1833, 1245, 1912, 535, 49, 1680, 1261, 462, 271, 608, 1177, 66, 846, 335, 1777, 1313, 1475, 1486, 1766, 883, 502,
  213, 1852, 1823, 943, 1382, 1162, 669, 1644, 377, 979, 1992, 1205, 1844, 2026, 1374, 373, 949, 477, 1438, 444, 526, 1185, 215, 1174, 1, 314,
  1338, 1000, 571, 1880, 1511, 1006, 468, 614, 276, 598, 195, 357, 1055, 827, 264, 1509, 765, 1166, 874, 1283, 1008, 1090, 1523, 122, 42, 374, 1994, 
  1124, 283, 40, 744, 291, 1387, 1794, 966, 643, 1659, 329, 391, 829, 1592, 880, 723, 1209, 358, 1409, 1421, 709, 871, 539, 296, 762, 1153, 466, 389,
  225, 1407, 1610, 1728, 1353, 1671, 488, 173, 984, 716, 236, 1990, 773, 1870, 1345, 1427, 692, 766, 566, 1242, 1016, 836, 823, 529, 334, 134, 1252,
  246, 594, 804, 118, 1228, 642, 604, 1748, 65, 1335, 1215, 1495, 1687, 1370, 421, 1871, 1419, 507, 574, 1167, 1036, 1219, 1067, 557, 1855, 1271, 1560,
  1410, 443, 1137, 579, 1768, 528, 1998, 342, 86, 1034, 863, 1989, 2052, 1893, 1801, 1792, 728, 1720, 1981, 1333, 467, 1924, 1685, 233, 1813, 783, 789,
  1292, 156, 1719, 1031, 1444, 1836, 1346, 1154, 1253, 251, 654, 867, 126, 927, 1955, 1047, 1568, 242, 1623, 504, 1829, 918, 426, 73, 1158, 150, 819,
  1666, 835, 1021, 2008, 1814, 1308, 1040, 886, 1809, 1011, 130, 300, 800, 565, 1413, 286, 430, 617, 1541, 875, 362, 152, 1195, 552, 1365, 872, 433,
  319, 252, 1262, 1991, 1150, 1401, 1790, 806, 638, 12, 1500, 149, 1573, 1812, 587, 889, 158, 164, 1467, 1532, 1663, 17, 1827, 1026, 509, 1567, 1779,
  1798, 2045, 35, 1550, 559, 1692, 1769, 750, 352, 1369, 1126, 1214, 82, 1082, 1602, 227, 778, 1851, 501, 1470, 851, 969, 147, 1942, 963, 613, 1184,
  26, 2030, 1507, 350, 977, 1580, 752, 839, 1843, 1875, 1607, 841, 1307, 1322, 626, 551, 1132, 366, 172, 361, 1009, 2009, 876, 1431, 720, 676, 849,
  321, 1134, 1474, 1250, 1954, 950, 269, 1921, 1515, 1383, 1736, 1734, 1895, 976, 1091, 1890, 273, 1418, 1061, 1156, 1270, 229, 686, 491, 185, 1506,
  1660, 262, 179, 101, 932, 1662, 1145, 1799, 1376, 1457, 1018, 1186, 596, 1854, 506, 1059, 1406, 85, 1263, 385, 1650, 930, 437, 1098, 1665, 1881, 
  1986, 178, 338, 1340, 1543, 1037, 1339, 793, 1920, 1514, 1558, 1658, 1169, 153, 312, 736, 1198, 127, 776, 1073, 1300, 928, 545, 702, 1945, 1657, 525,
  1378, 1713, 1978, 1730, 111, 850, 1477, 1216, 1695, 1631, 208, 583, 414, 485, 1282, 1947, 2035, 1795, 1142, 1480, 1379, 786, 991, 1429, 988, 1412,
  962, 1703, 1092, 1761, 1939, 1463, 1832, 658, 1965, 622, 1604, 730, 19, 1600, 925, 1359, 1088, 1806, 1727, 1937, 1289, 483, 1504, 1637, 254, 1352,
  58, 313, 89, 1181, 308, 1111, 607, 785, 1512, 1887, 486, 1899, 1109, 1739, 523, 287, 1715, 712, 231, 1490, 1165, 448, 690, 1125, 748, 1078, 1152,
  155, 934, 1711, 1735, 435, 1747, 1298, 1860, 1642, 591, 247, 754, 310, 1968, 1535, 1622, 343, 1380, 365, 97, 1755, 919, 1505, 2043, 1930, 1763, 1648,
  630, 1565, 1128, 1546, 1752, 1497, 157, 456, 534, 299, 907, 1481, 1529, 33, 1818, 631, 1926, 972, 384, 135, 226, 1251, 954, 1301, 1817, 803, 1230,
  544, 3, 294, 890, 1314, 1093, 1538, 420, 1193, 2002, 451, 345, 439, 1415, 899, 983, 1375, 346, 625, 386, 285, 1835, 797, 1019, 1570, 2006, 1548, 953,
  1221, 1341, 1878, 1595, 1389, 1590, 454, 1069, 98, 921, 201, 671, 1342, 1075, 733, 116, 1916, 549, 577, 1927, 1218, 562, 856, 527, 1260, 740, 1033,
  265, 556, 645, 1054, 1847, 1696, 351, 1956, 1299, 1157, 387, 1107, 1160, 1862, 570, 619, 1175, 530, 882, 1462, 327, 493, 1640, 200, 1023, 113, 1563,
  234, 123, 959, 753, 349, 249, 994, 582, 639, 203, 1667, 379, 1581, 996, 399, 808, 1074, 1472, 869, 1201, 90, 1839, 163, 1791, 1778, 1430, 1423, 376,
  2033, 1368, 1287, 112, 759, 575, 1654, 50, 45, 344, 554, 1584, 1498, 255, 1103, 1390, 1354, 1638, 833, 1358, 1323, 1846, 36, 102, 1064, 31, 1591,
  1894, 197, 1066, 119, 742, 615, 1928, 1366, 1012, 518, 307, 879, 311, 2040, 987, 1911, 1275, 1614, 193, 688, 624, 891, 1596, 1683, 1980, 1652, 1170,
  0, 1598, 1395, 1698, 649, 217, 239, 710, 1071, 724, 1321, 1305, 560, 169, 180, 1626, 610, 1805, 364, 2037, 1877, 1771, 1179, 2039, 2044, 955, 224,
  1141, 1944, 1269, 205, 166, 1029, 847, 1386, 476, 1929, 142, 209, 1582, 21, 2, 1606, 267, 521, 970, 623, 445, 1705, 1310, 74, 253, 913, 1826, 245,
  1453, 821, 505, 1331, 348, 1738, 1244, 1223, 2041, 1460, 1001, 834, 893, 302, 2038, 832, 219, 500, 63, 438, 831, 1381, 132, 703, 672, 1432, 322, 237,
  1639, 859, 84, 64, 1041, 1492, 1873, 909, 1744, 353, 434, 718, 1753, 461, 407, 447, 41, 1234, 1629, 1987, 2032, 1398, 1621, 1884, 1594, 751, 261,
  167, 734, 230, 1824, 968, 1065, 333, 1625, 1255, 330, 1613, 18, 777, 204, 1447, 1268, 584, 235, 277, 7, 1468, 1396, 115, 1557, 1526, 1757, 1015, 1796,
  1014, 1159, 1891, 1633, 1861, 999, 168, 316, 1164, 1673, 1361, 1628, 729, 885, 1856, 801, 737, 787, 634, 460, 915, 864, 601, 1445, 161, 828, 499, 480,
  471, 278, 946, 1767, 1440, 1859, 1337, 2051, 1028, 1206, 363, 1670, 1080, 1068, 1364, 232, 697, 2024, 1057, 1979, 2046, 1577, 725, 1840, 1866, 914,
  824, 2023, 2004, 758, 1120, 323, 940, 1102, 1969, 866, 1751, 1211, 1865, 241, 923, 1187, 1940, 1007, 1972, 881, 973, 1469, 1200, 989, 2028, 479, 908,
  13, 887, 1178, 22, 383, 2047, 1439, 745, 855, 664, 410, 214, 2048, 449, 838, 93, 685, 693, 354, 755, 795, 160, 1433, 1020, 1224, 1279, 673, 816, 741,
  1149, 1923, 1316, 1760, 1635, 442, 938, 1350, 1776, 408, 1274, 900, 452, 650, 1749, 207, 1612, 301, 1249, 1400, 1664, 298, 1903, 146, 1176, 371, 2010,
  487, 618, 143, 726, 1936, 812, 1620, 1985, 555, 1932, 896, 1898, 794, 646, 1197, 1399, 1745, 1051, 981, 174, 1910, 699, 1388, 628, 2005, 1344, 1516,
  854, 1225, 1348, 1765, 768, 1045, 567, 388, 1618, 39, 1113, 183, 1425, 1521]
  
  # 乱数テーブルのサイズ
  @@rand_max = @@rand_table.size
  
end




module Coordinate
  # ラジアンを求める :value(角度)
  def radian(value)
    ((value % 360) / 180.0) * Math::PI
  end

  # sin値を求める :value(角度)
  def sin(value) 
    Math::sin(radian(value))
  end

  # cos値を求める :value(角度)
  def cos(value) 
    Math::cos(radian(value))
  end
 
  # 円周上の座標のsin値を求める :value(角度)
  def round_sin(value) 
    sin(value)
  end

  # 円周上の座標のcos値を求める :value(角度)
  def round_cos(value)
    cos(value)
  end
  
  # ベクトルX値とY値から角度を求める
  def vector_to_angle(vector_x, vector_y, angle = 0)
    # ベクトルが0の場合0度
    if vector_x == 0 and vector_y == 0
      return angle
    # ベクトルXが0の場合
    elsif vector_x == 0
      return (vector_y < 0 ? 0: 180)
    # ベクトルYが0の場合
    elsif vector_y == 0
      return (vector_x < 0 ? 90: 270)
    # 両ベクトルが0でない場合
    else
      tan = (vector_x) / (vector_y)
      angle = (Math::atan(tan)  * 180 / Math::PI).round
      angle = angle + (vector_y > 0 ? 180: 0) 
      return angle
    end
  end 
 
  # 原点から円周上の座標までの半径を求める
  def round_radius(x, y)
    value = x ** 2 + y ** 2
    Math::sqrt(value).round
  end

  # 合成サイン波を返す # pahse_siht:位相
  def composition_sin(value, phase_shift = 0, partition = 1)
    (sin(value) + sin((value + phase_shift) * partition)) / 2
  end
 
  # 線形補完値を返す
  def liner(ps, pe, time, duration)
    ps + (pe - ps) * time / duration
  end

  # スプライン補完値を返す
  def spline(ps, pe, pc, t, tc)
    (tc ** 2) * ps + 2 * t * tc * pc + (t ** 2) * pe
  end

  # ベジェ補完値を返す
  def bezier(ps, pe, cs, ce, t, tc)
    (tc ** 3) * ps + 3 * (tc ** 2) * t * cs + 3 * tc * (t ** 2) * ce + (t ** 3) * pe
  end
end




