
    /*NOTE: This file is automatically generated by the build process. Modifications will be lost.*/
    IF  EXISTS (SELECT * FROM sys.assemblies asms WHERE asms.name = N'log4mssql' and is_user_defined = 1)
    DROP ASSEMBLY [log4mssql]
    GO
    
    CREATE ASSEMBLY [log4mssql]
    FROM 0x4D5A90000300000004000000FFFF0000B800000000000000400000000000000000000000000000000000000000000000000000000000000000000000800000000E1FBA0E00B409CD21B8014CCD21546869732070726F6772616D2063616E6E6F742062652072756E20696E20444F53206D6F64652E0D0D0A2400000000000000504500004C0103008469745C0000000000000000E00002210B010800001600000006000000000000CE350000002000000040000000004000002000000002000004000000000000000400000000000000008000000002000000000000030040850000100000100000000010000010000000000000100000000000000000000000803500004B000000004000001803000000000000000000000000000000000000006000000C00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000200000080000000000000000000000082000004800000000000000000000002E74657874000000D4150000002000000016000000020000000000000000000000000000200000602E7273726300000018030000004000000004000000180000000000000000000000000000400000402E72656C6F6300000C0000000060000000020000001C00000000000000000000000000004000004200000000000000000000000000000000B035000000000000480000000200050038270000480E000001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000001B300400470300000100001100730500000A0A0F01280600000A0B0F00280600000A7201000070280700000A0C730800000A0D09046F0900000A6F0A00000A0000096F0B00000A6F0C00000A130A38D7010000110A6F0D00000A740E0000011304000011046F0B00000A6F0C00000A130B3883010000110B6F0D00000A740E00000113050011056F0E00000A14FE0116FE01130C110C2D0600385B0100000F04280F00000A11056F0E00000A721F0000706F1000000A14FE0116FE015F16FE01130C110C2D3400281100000A723B00007011056F0E00000A721F0000706F1000000A6F1200000A11056F1300000A281400000A6F1500000A000011056F0E00000A721F0000706F1000000A14FE01130C110C3AE100000000066F1600000A1306110611056F0E00000A721F0000706F1000000A6F1200000A6F1700000A0011056F0E00000A729F0000706F1000000A14FE01130C110C2D34001106D017000001281800000A11056F0E00000A729F0000706F1000000A6F1200000A281900000AA5170000016F1A00000A000011056F0E00000A72AD0000706F1000000A14FE01130C110C2D340011056F0E00000A72AD0000706F1000000A6F1200000A1207281B00000A16FE01130C110C2D0C00110611076F1C00000A000000110611056F1300000A6F1D00000A00066F1E00000A11066F1F00000A260000110B6F2000000A130C110C3A6DFEFFFFDE1D110B751D000001130D110D14FE01130C110C2D08110D6F2100000A00DC0000110A6F2000000A130C110C3A19FEFFFFDE1D110A751D000001130D110D14FE01130C110C2D08110D6F2100000A00DC0008732200000A13080011086F2300000A0006176F2400000A0006076F2500000A000611086F2600000A000F04280F00000A16FE01130C110C3A9400000000281100000A72B700007011086F2700000A066F2800000A281400000A6F1500000A0000066F1E00000A6F2900000A130A2B33110A6F0D00000A7415000001130900281100000A720901007011096F2A00000A11096F2B00000A281400000A6F1500000A0000110A6F2000000A130C110C2DC0DE1D110A751D000001130D110D14FE01130C110C2D08110D6F2100000A00DC0000066F2C00000A2611086F2D00000A0000DE14110814FE01130C110C2D0811086F2100000A00DC002A004164000002000000650000009A010000FF0100001D000000000000000200000042000000EE010000300200001D0000000000000002000000BC02000044000000000300001D000000000000000200000056020000DB0000003103000014000000000000001E02282E00000A2A1B300300CB00000002000011000E047E2F00000A733000000A8102000001000F00283100000A2D120F01283100000A2D090F02283200000A2B01170D092D64000F01280600000A283300000A0A06283400000A0D092D0706283500000A260F01280600000A0F02280F00000A733600000A0B0007028C020000016F3700000A0000DE100714FE010D092D07076F2100000A00DC000516733800000A8104000001002B0C0517733800000A810400000100DE230C000E04086F3900000A733000000A81020000010515733800000A810400000100DE00002A00011C00000200660011770010000000000000120094A60023280000011B300600B90000000300001100000F00283100000A0D093A8E000000000F00280600000A733A00000A0A00178D2A0000011304110416723D0100701F0C283B00000A733C00000AA21104733D00000A0B281100000A076F3E00000A002B1C000716066F3F00000A6F4000000A00281100000A076F4100000A0000066F4200000A16FE0416FE010D092DD4281100000A6F4300000A0000DE100614FE010D092D07066F2100000A00DC000000DE160C00281100000A086F3900000A6F1500000A0000DE00002A000000011C000002001E006E8C00100000000000000100A0A10016280000011E02282E00000A2A1B3003000A01000004000011000E057E2F00000A733000000A8102000001000F00283100000A2D120F01283100000A2D090F02283200000A2B0117130411043A9C000000000F01280600000A283300000A0A06283400000A130411042D0706283500000A26160F03280600000A734400000A0B00076F4500000A260F01280600000A0F02280F00000A733600000A0C0008028C020000016F3700000A0000DE120814FE01130411042D07086F2100000A00DC00076F4600000A0000DE120714FE01130411042D07076F2100000A00DC000E0416733800000A8104000001002B0D0E0417733800000A810400000100DE240D000E05096F3900000A733000000A81020000010E0415733800000A810400000100DE00002A000001280000020083001194001200000000020067004AB100120000000000001200D2E40024280000011E02282E00000A2A42534A4201000100000000000C00000076322E302E35303732370000000005006C00000084040000237E0000F00400007C06000023537472696E6773000000006C0B00004801000023555300B40C0000100000002347554944000000C40C00008401000023426C6F620000000000000002000001471502000900000000FA013300160000010000002E000000040000000700000011000000460000000600000004000000010000000300000000000A000100000000000600770070000A009F008A000A00A9008A000A00B0008A000A00B9008A0006007A015B010600BE019E010600DE019E010A001702FC010A0043022D020600580270000E00710266020E007D0266020E00990266020E00A10266020600CF02BC020E00F50266020E001B0366020A003303FC010A003E03FC010A0069032D020A00990386030A00B7037E000600C10370000600C60370000600EA0370000600030470000A0025042D020600580470000A006C042D020A007A0486030A008C0486030A0096047E000A00EE048603060047053D0506005D053D0506006E053D0506008C053D05060099053D050600AE0570000600C4053D050A00D105FC010A00E505FC01060004063D0506005606450606005C06450600000000010000000000010001000100100033000000050001000100010010004400000005000100030001001000530000000500010006005020000000009600C4000A0001000824000000008618E900180006001024000000009600EF001C0006000425000000009600FD002C000B00E825000000008618E90018000C00F025000000009600EF0032000C003027000000008618E90018001200000001000A01000002001B01000003002101000004002C01000005003B01000001004101000002004601000003004B01020004005201020005008701000001004601000001004101000002004601000003004B010000040094010200050052010200060087013100E90018003900E90044004100E90018004900E90018005100E900180011004E024E0059005F0252006100E9001800190087025800610094025D007100AD0263007900DB0268008100E9026D0071000C03710029004E027600890028037A0099004603800071004E024E0071004F034E0059005D038500A10064038C00510076039100B100A5038C00C100D8039600D100EF039D00A900F503A400D9000904AA00B10012044400B1001B04B10051003C04B600E1004B04BB0081004F047600E90064041800F100E9008C00F900870418000101A204C2000101B2048C005100C204C900F900D1044E000101DE044E001101DB026800B10004054E00B1004E026D0001011605CF00F900260518000900E900180059002C05EE001100E9008C0011003205760029003205760019014C05F10021016705F60021017C05FB003101E90002013901A405B1002100E90044004101B8054E004901E9008C005101DD0513015101E90017015901E9001F01A100F305270161010F064E00590118062E01A1002206270161013106CF00A100360618006901E900450171016706760069016F0618002000230049002E00130059012E001B006201600023004900800023004900C00023004900D300080134014B01048000000000000000000000000000000000C4000000020000000000000000000000010067000000000002000000000000000000000001007E0000000000020000000000000000000000010066020000000000000000003C4D6F64756C653E004C6F67676572426173655F457865635F4E6F6E5F5472616E7361637465645F51756572792E646C6C0053746F72656450726F636564757265730052656164577269746546696C657300577269746546696C6573576974684D75746578006D73636F726C69620053797374656D004F626A6563740053797374656D2E446174610053797374656D2E446174612E53716C54797065730053716C537472696E670053716C586D6C0053716C496E7433320053716C426F6F6C65616E004C6F67676572426173655F457865635F4E6F6E5F5472616E7361637465645F5175657279002E63746F720057726974655465787446696C6500526561645465787446696C6500436F6E6E656374696F6E537472696E6700517565727900506172616D657465727300436F6D6D616E6454696D656F75740044656275670074657874007061746800617070656E640065786974436F64650053797374656D2E52756E74696D652E496E7465726F705365727669636573004F7574417474726962757465006572726F724D657373616765006D757465786E616D650053797374656D2E52756E74696D652E436F6D70696C6572536572766963657300436F6D70696C6174696F6E52656C61786174696F6E734174747269627574650052756E74696D65436F6D7061746962696C697479417474726962757465004D6963726F736F66742E53716C5365727665722E5365727665720053716C50726F6365647572654174747269627574650053797374656D2E446174612E53716C436C69656E740053716C436F6D6D616E64006765745F56616C756500537472696E6700436F6E6361740053797374656D2E586D6C00586D6C446F63756D656E7400586D6C52656164657200437265617465526561646572004C6F616400586D6C4E6F646500586D6C4E6F64654C697374006765745F4368696C644E6F6465730053797374656D2E436F6C6C656374696F6E730049456E756D657261746F7200476574456E756D657261746F72006765745F43757272656E7400586D6C417474726962757465436F6C6C656374696F6E006765745F4174747269627574657300586D6C417474726962757465006765745F4974656D4F660053716C436F6E746578740053716C50697065006765745F50697065006765745F496E6E65725465787400466F726D61740053656E640053716C506172616D6574657200437265617465506172616D657465720053797374656D2E446174612E436F6D6D6F6E004462506172616D65746572007365745F506172616D657465724E616D650053716C44625479706500547970650052756E74696D655479706548616E646C65004765745479706546726F6D48616E646C6500456E756D005061727365007365745F53716C44625479706500496E743332005472795061727365007365745F53697A65007365745F56616C75650053716C506172616D65746572436F6C6C656374696F6E006765745F506172616D657465727300416464004D6F76654E6578740049446973706F7361626C6500446973706F73650053716C436F6E6E656374696F6E004462436F6E6E656374696F6E004F70656E004462436F6D6D616E6400436F6D6D616E6454797065007365745F436F6D6D616E6454797065007365745F436F6D6D616E6454657874007365745F436F6E6E656374696F6E006765745F4461746162617365006765745F436F6D6D616E6454657874004462506172616D65746572436F6C6C656374696F6E006765745F506172616D657465724E616D6500457865637574654E6F6E517565727900436C6F736500456D707479006765745F49734E756C6C0053797374656D2E494F0050617468004765744469726563746F72794E616D65004469726563746F727900457869737473004469726563746F7279496E666F004372656174654469726563746F72790053747265616D57726974657200546578745772697465720057726974654C696E6500457863657074696F6E006765745F4D6573736167650053747265616D5265616465720053716C4D65746144617461006765745F4D61780053716C446174615265636F72640053656E64526573756C74735374617274005465787452656164657200526561644C696E6500536574537472696E670053656E64526573756C7473526F77005065656B0053656E64526573756C7473456E640053797374656D2E546872656164696E67004D75746578005761697448616E646C6500576169744F6E650052656C656173654D7574657800001D3B0045006E006C006900730074003D00660061006C00730065003B00001B50006100720061006D0065007400650072004E0061006D0065000063500072006F00630065007300730069006E006700200070006100720061006D006500740065007200200027007B0030007D00270020007700690074006800200061002000760061006C007500650020006F006600200027007B0031007D0027002E00010D4400420054007900700065000009530069007A006500005143006F006E006E0065006300740069006E006700200074006F0020007B0030007D00200061006E0064002000730065006E00640069006E0067002000710075006500720079003A0020007B0031007D00003350006100720061006D0065007400650072003A0020007B0030007D002000560061006C00750065003A0020007B0031007D0000094C0069006E006500000052DFB03B69EC5341BFE10EBB981EF0430008B77A5C561934E0890D00050111091109120D11111115032000010F000501110911091115101111101109050001011109110006011109110911151109101111101109042001010804010000000320000E0500020E0E0E0420001235052001011235042000123D04200012410320001C04200012450320000205200112490E04000012510600030E0E1C1C042001010E0420001255060001126111650600021C12610E05200101115D060002020E1008042001011C04200012710620011255125506200101118085052001011279032000081A070E12290E0E123112391239125508127912551241124102127502060E0400010E0E040001020E0600011280950E052002010E020A07040E1280991280A1020300000A072003010E115D0A072001011D1280A9062001011280AD05200201080E1007051280A51280AD1280A1021D1280A905200201020E0D07050E1280B51280991280A1020801000800000000001E01000100540216577261704E6F6E457863657074696F6E5468726F777301000000A83500000000000000000000BE350000002000000000000000000000000000000000000000000000B03500000000000000005F436F72446C6C4D61696E006D73636F7265652E646C6C0000000000FF2500204000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000100100000001800008000000000000000000000000000000100010000003000008000000000000000000000000000000100000000004800000058400000BC0200000000000000000000BC0234000000560053005F00560045005200530049004F004E005F0049004E0046004F0000000000BD04EFFE00000100000000000000000000000000000000003F000000000000000400000002000000000000000000000000000000440000000100560061007200460069006C00650049006E0066006F00000000002400040000005400720061006E0073006C006100740069006F006E00000000000000B0041C020000010053007400720069006E006700460069006C00650049006E0066006F000000F801000001003000300030003000300034006200300000002C0002000100460069006C0065004400650073006300720069007000740069006F006E000000000020000000300008000100460069006C006500560065007200730069006F006E000000000030002E0030002E0030002E003000000074002900010049006E007400650072006E0061006C004E0061006D00650000004C006F00670067006500720042006100730065005F0045007800650063005F004E006F006E005F005400720061006E007300610063007400650064005F00510075006500720079002E0064006C006C00000000002800020001004C006500670061006C0043006F0070007900720069006700680074000000200000007C00290001004F0072006900670069006E0061006C00460069006C0065006E0061006D00650000004C006F00670067006500720042006100730065005F0045007800650063005F004E006F006E005F005400720061006E007300610063007400650064005F00510075006500720079002E0064006C006C0000000000340008000100500072006F006400750063007400560065007200730069006F006E00000030002E0030002E0030002E003000000038000800010041007300730065006D0062006C0079002000560065007200730069006F006E00000030002E0030002E0030002E00300000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000003000000C000000D035000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
    WITH PERMISSION_SET = UNSAFE
    GO
    
