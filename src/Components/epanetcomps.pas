{ This file was automatically created by Lazarus. Do not edit!
This source is only used to compile and install the package.
 }

unit EpanetComps; 

interface

uses
  NumEdit, VirtList, LazarusPackageIntf; 

implementation

procedure Register; 
begin
  RegisterUnit('NumEdit', @NumEdit.Register); 
  RegisterUnit('VirtList', @VirtList.Register); 
end; 

initialization
  RegisterPackage('EpanetComps', @Register); 
end.
