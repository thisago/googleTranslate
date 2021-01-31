##  #include <iostream>
##  using namespace std;

proc logicalRightShift*(x: cint; n: cint): cint =
  return cast[cuint](x) shr n

proc arithmeticRightShift*(x: cint; n: cint): cint =
  if x < 0 and n > 0:
    return x shr n or not (not 0 shr n)
  else:
    return x shr n

proc logical_right_shift*(x: cint; n: cint): cint =
  var size: cint = sizeof((int) * 8)
  ##  usually sizeof(int) is 4 bytes (32 bits)
  return (x shr n) and not (((0x00000001 shl size) shr n) shl 1)

##  int main() {
##  cout << logicalRightShift(-25355305, 6) << "\n"; //== 66712687
##  cout << arithmeticRightShift(-25355305, 6) << "\n"; //== 66712687
##  cout << logicalRightShift(-1727632372, 11) << "\n"; //== 1253581
##  cout << arithmeticRightShift(-1727632372, 11) << "\n"; //== 1253581
##  cout << logicalRightShift(25355305, 6) << "\n"; //== 396176
##  cout << arithmeticRightShift(25355305, 6) << "\n"; //== 396176
##  cout << logicalRightShift(1727632372, 11) << "\n"; //== 843570
##  cout << arithmeticRightShift(1727632372, 11) << "\n"; //== 843570
##  // cout << (0U == 0) << endl;
##  // cout << (~0U) << endl;
##  // cout << (~0) << endl;
##  // cout << (~843570) << endl;
##  // cout << (~843570U) << endl;
##  // cout << (~-843570U) << endl;
##  }
