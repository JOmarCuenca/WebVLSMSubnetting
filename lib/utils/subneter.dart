import 'dart:math';

import 'package:flutter/material.dart';

///Enum that describes the type of networks that exist.
enum NetworkType { none, a, b, c, d, e}

///Enum extension to know exactly how many sets of 8 bits each type of network use default as mask.
extension octal on NetworkType {
  int get val{
    switch(this){
      case NetworkType.a:
        return 1;
      case NetworkType.b:
        return 2;
      case NetworkType.c:
        return 3;
      case NetworkType.d:
        return 4;
      default:
        return -1;
    }
  }
}

///Turns a binary number into an int.
int binaryToInt(String binary){
  int result = 0;
  int power = 1;
  final chars = binary.runes.toList();
  for(int i = chars.length-1;i>=0;i--){
    result += power*int.parse(new String.fromCharCode(chars[i]));
    power *= 2;
  }
  return result;
}

///Splits a Network into bits without point for easier manipulation.
String getBits(String network){
  final temp = network.split(".");
  if(network.isEmpty || temp.length != 4){
    return "";
  }
  try{
    String result = "";
    temp.forEach((part) { 
      String binary = int.parse(part).toRadixString(2);
      while(binary.length<8){
        binary = "0"+binary;
      }
      result+=binary;
    });
    return result;
  } catch (e) {
    print(e);
    return "";
  }
}

///# Binary Class 
///## To handle a couple of operations of Binary numbers
///
///Allows for easier manipulation of strings that have a format of 
///Binary numbers, while remaining with same string length.
///
///Meaning that if I send 010101 and add 1. The leftmost 0 will still be there after the operation.
class Binary{

  String _bits;
  int _value,_length;

  Binary(int number){
    this._value = number;
    this._bits = number.toRadixString(2);
    this._length = this._bits.length;
  }

  void setLength(int length) {
    this._length = length;
    while(this._bits.length<length){
      this._bits = "0" + this._bits;
    }
  }

  void minusOne(){
    this._value--;
    this._bits = this._value.toRadixString(2);
    while(this._bits.length<this._length){
      this._bits = "0" + this._bits;
    }
    this._length = this._bits.length;
  }

  void plusOne(){
    this._value++;
    this._bits = this._value.toRadixString(2);
    while(this._bits.length<this._length){
      this._bits = "0" + this._bits;
    }
    this._length = this._bits.length;
  }

  String get bits {
    return this._bits;
  }

  static Binary fromLength(int size){
    return new Binary(pow(2,size) -1 );
  }

  static Binary fromString(String bits,int length){
    final Binary temp = new Binary(binaryToInt(bits));
    temp.setLength(length);
    return temp;
  }

}

///Return the class of network according to the first 8 bit set.
NetworkType getDefaultMask(String n){
  try{
    final number = int.parse(n.split(".")[0]);
    if(number > 239){
      return NetworkType.d;
    } else if(number > 223){
      return NetworkType.e;
    } else if(number > 191){
      return NetworkType.c;
    } else if(number > 127){
      return NetworkType.b;
    } else if(number > 0){
      return NetworkType.a;
    } else {
      throw new Exception("Not a type of network");
    }
  } catch (e) {
    return NetworkType.none;
  }
}

///# Subnet Class
///## A class used as interface for external easier printability
///
///Transforms the list of Strings sent to it to a format like a subnet.
///>> Like this - 127.0.0.1
///
///And saves it to each attribuite so it can be printed elsewhere more easily.
class Subnet{

  String id,firstHost,lastHost,broadcast,mask;
  int desiredHosts;

  Subnet(List<String> network,int hosts){
    this.id           = this._bitToNet(network[0]);
    this.firstHost    = this._bitToNet(network[1]);
    this.lastHost     = this._bitToNet(network[2]);
    this.broadcast    = this._bitToNet(network[3]);
    this.mask         = this._bitToNet(network[4]);
    this.desiredHosts = hosts;
  }

  String _bitToNet(String bits){
    String result = "";
    for(int i = 0;i<32;i+=8){
      final subS = bits.substring(i,i+8);
      final decimal = binaryToInt(subS);
      result += decimal.toString();
      if(i<32-8){
        result += ".";
      }
    }
    return result;
  }
}

///Due to the input format
///>> 120x3
///
///This method returns a list like 
///>>[120,120,120]
List<int> networkRepetitions(String network){
  if(network == null || network.isEmpty){
    return [];
  }
  network = network.toLowerCase();
  final temp = network.split("x");
  try{
    switch(temp.length){
      case 1:
        return [int.parse(temp[0])];
      case 2:
        final times = int.parse(temp[1]);
        final hosts = int.parse(temp[0]);
        final result = new List<int>(times);
        for(int i = 0; i<times;i++){
          result[i] = hosts;
        }
        return result;
      default:
        return [];
    }
  } catch (e) {
    return [];
  }
}

///## Sorts the desired networks
///
///Cleans the list of textFields into a list of ints contianing the desired number of hosts.
///And sorts them because of the rules of subnetting by VLSM.
List<int> cleanFields(List<TextEditingController> fields){
  final temp  = fields.map((e) => e.text);
  final List<int> hosts = [];
  temp.forEach((host){
    hosts.addAll(networkRepetitions(host));
  });
  hosts.sort();
  return hosts;
}

///# Generates the Subnets
///
///This method recieve the info so it can generate the subnets for final release.
Subnet generateSubnet(String net,NetworkType mask,int hosts){
  final ips = new List<String>(5);
  ips[0] = net;
  int power = 2;
  while((pow(2, power)-2)<hosts){
    power++;
  }
  final locked = 8*mask.val;
  if((32 - locked)<power){
    throw new Exception("Not enough space");
  }
  final lockedBits = net.substring(0,locked);
  final netBits = net.substring(locked,(32 - power));
  String hostBits = net.substring(32 - power);
  Binary hostBinary = Binary.fromString(hostBits, hostBits.length);
  hostBinary.plusOne();
  ips[1] = lockedBits + netBits + hostBinary.bits;
  hostBinary = Binary.fromLength(power);
  ips[3] = lockedBits + netBits + hostBinary.bits;
  hostBinary.minusOne();
  ips[2] = lockedBits + netBits + hostBinary.bits;
  ips[4] = Binary.fromLength(32 - power).bits + Binary.fromString("0", power).bits;
  final nextNetwork = Binary.fromString(ips[3], 32);
  nextNetwork.plusOne();
  net = nextNetwork.bits;
  return new Subnet(ips,hosts);
}

///Gets the next subnet after calculating the hosts for the last network
String nextNetwork(String network){
  const networkLength = 32;
  final bits = getBits(network);
  final networkBinary = Binary.fromString(bits, networkLength);
  networkBinary.plusOne();
  return networkBinary.bits;
}

///This is the master module that calls everything else
///
///## ENTRY POINT
List<Subnet> subnet(String network, List<TextEditingController> hostFields){
  final hosts = cleanFields(hostFields);
  String net = getBits(network);
  final defaultMask = getDefaultMask(network);
  if(defaultMask == NetworkType.d || defaultMask == NetworkType.e || defaultMask == NetworkType.none){
    return [];
  }
  final result = new List<Subnet>();
  bool ok = true;
  while(ok && hosts.length>0){
    try{
      final targetHost = hosts.removeLast();
      final subnet = generateSubnet(net,defaultMask,targetHost);
      result.add(subnet);
      net = nextNetwork(subnet.broadcast);
    } catch (e){
      print(e);
      ok = false;
    }
  }
  return result;
}