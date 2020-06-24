var _text = @'[Section 1]
; comment
Option 1 = value 1                     ; option "Option 1" has value "value 1"
oPtion 1    =  \ value 2\ \ \          ; option "oPtion 1" has value " value 2   ", "oPtion 1" and "Option 1" are different

[Numbers]
num = "-1285"
num_bin = 0b01101001
num_hex = 0x12ae
num_oct = 01754

float1 = -124.45667356
float2 = +4.1234565E+45
float3 = 412.34565e45
float4 = -1.1245864E-6

[Other]
bool1 = 1
bool2 = on
bool3=f';

show_debug_message(snap_to_json(snap_from_ini_string(_text, false), true, true));