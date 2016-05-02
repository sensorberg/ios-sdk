//
//  CBCharacteristic+SBCharacteristic.m
//  Pods
//
//  Created by Andrei Stoleru on 08/03/16.
//
//

#import "CBCharacteristic+SBCharacteristic.h"

#import <objc/runtime.h>

#import "CBPeripheral+SBPeripheral.h"

@implementation CBCharacteristic (SBCharacteristic)

- (BOOL)matchesUUID:(NSUInteger)uuid {
    
    return uuid==[self swappedIdentifier];
}

- (NSString *)title {
    NSString *res = @"Unknown property";
    //
    if (!self || !self.UUID) {
        return res;
    }
    //
    switch ([self swappedIdentifier]) {
        case iBLESystem:
            res = @"System ID";
            break;
        case iBLEModel:
            res = @"Model";
            break;
        case iBLESerialNumber:
            res = @"Serial Number";
            break;
        case iBLEFirmwareRev:
            res = @"Firmware rev.";
            break;
        case iBLEHardwareRev:
            res = @"Hardware rev.";
            break;
        case iBLESoftwareRev:
            res = @"Software rev.";
            break;
        case iBLEManufacturer:
            res = @"Manufacturer";
            break;
        case iBLEIEE:
            res = @"IEEE Certification";
            break;
        case iBLEPNP:
            res = @"PnP ID";
            break;
        case iBKSUUID:
            res = @"Proximity UUID";
            break;
        case iBKSMajor:
            res = @"Major";
            break;
        case iBKSMinor:
            res = @"Minor";
            break;
        case iBKSTxPwr:
            res = @"TxPower";
            break;
        case iBKSCPwr:
            res = @"Calibrated Power";
            break;
        case iBKSAdv:
            res = @"Advertising interval";
            break;
        case iBKSCfg:
            res = @"Configuration mode";
            break;
        case iBKSPwd:
            res = @"Lock";
            break;
        case iBKSStatus:
            res = @"Status";
            break;
        default:
            res = [NSString stringWithFormat:@"%@",self.UUID];
            break;
    }
    return res;
}

- (NSString*)detail {
    NSString *res = @"-";
    
    if (!self || !self.UUID) {
        return res;
    }
    NSLog(@"got self.UUID");
    //
    NSData *cValue = [self value];
    if (!cValue) {
        return res;
    }
    NSLog(@"got value");
    //
    uint16_t swapped = [self swappedIdentifier];
    NSLog(@"got swapped: %i",swapped);
    //
    switch (swapped) {
        case iBLESystem:
        case iBLEIEE:
        case iBLEPNP:
        {
            res = [NSString stringWithFormat:@"%@",cValue];
            break;
        }
        case iBLEModel:
        case iBLESerialNumber:
        case iBLEFirmwareRev:
        case iBLEHardwareRev:
        case iBLESoftwareRev:
        case iBLEManufacturer:
        {
            res = [[NSString alloc] initWithData:cValue encoding:NSUTF8StringEncoding];
            break;
        }
        case iBKSUUID:
        {
            CBUUID *u = [CBUUID UUIDWithData:self.value];
            res = [NSString stringWithFormat:@"%@", u.UUIDString];
            break;
        }
        case iBKSMajor:
        {
            int majorValue = 0;
            NSLog(@"getting major");
            [cValue getBytes:&majorValue length:2];
            NSLog(@"got major");
            res = [NSString stringWithFormat:@"%i",CFSwapInt16(majorValue)];
            break;
        }
        case iBKSMinor:
        {
            int minorValue = 0;
            NSLog(@"getting minor");
            [cValue getBytes:&minorValue length:2];
            NSLog(@"got minor");
            res = [NSString stringWithFormat:@"%i",CFSwapInt16(minorValue)];
            break;
        }
        case iBKSTxPwr:
        {
            int txValue = 0;
            NSLog(@"getting tx");
            [cValue getBytes:&txValue length:1];
            NSLog(@"got tx");
            SBFirmwareVersion fw = [self.service.peripheral firmware];
            if (fw==iBKS105v1) {
                if (txValue==0) {
                    res = @"-30";
                } else if (txValue==1) {
                    res = @"-20";
                } else if (txValue==2) {
                    res = @"-16";
                } else if (txValue==3) {
                    res = @"-12";
                } else if (txValue==4) {
                    res = @"-8";
                } else if (txValue==5) {
                    res = @"-4";
                } else if (txValue==6) {
                    res = @"-0";
                } else if (txValue==7) {
                    res = @"+4";
                }
            } else if (fw==iBKSUSB) {
                if (txValue==0) {
                    res = @"-23";
                } else if (txValue==1) {
                    res = @"-6";
                } else if (txValue==2) {
                    res = @"0";
                } else if (txValue==3) {
                    res = @"4";
                }
            }
            
            break;
        }
        case iBKSCPwr:
        {
            int cpwValue = 0;
            NSLog(@"getting cpwr");
            [cValue getBytes:&cpwValue length:1];
            NSLog(@"got cpwr");
            res = [NSString stringWithFormat:@"%i",cpwValue];
            //
            break;
        }
        case iBKSAdv:
        {
            int advValue = 0;
            NSLog(@"getting advI");
            [cValue getBytes:&advValue length:2];
            NSLog(@"got advI");
            res = [NSString stringWithFormat:@"%i",CFSwapInt16(advValue)];
            break;
        }
        case iBKSCfg:
        {
            int cfgValue = 0;
            NSLog(@"getting cfg");
            [cValue getBytes:&cfgValue length:1];
            NSLog(@"got cfg");
            switch (cfgValue) {
                case 0x1A:
                {
                    res = @"Standard configuration";
                    break;
                }
                case 0x1B:
                {
                    res = @"Broad. battery level";
                    break;
                }
                case 0x9A:
                {
                    res = @"Developer mode";
                    break;
                }
                case 0x9B:
                {
                    res = @"Dev mode + battery level";
                    break;
                }
                case 0xFF:
                {
                    res = @"Firmware upgrade";
                    break;
                }
                default:
                    res = [NSString stringWithFormat:@"%i",cfgValue];
                    break;
            }
            break;
        }
        case iBKSPwd:
        {
            int pwdValue = 0;
            NSLog(@"getting pwd");
            [cValue getBytes:&pwdValue length:2];
            NSLog(@"got pwd");
            if (CFSwapInt16(pwdValue)==0) {
                res = @"Unlocked";
            }
            res = @"Locked";
            break;
        }
        case iBKSStatus:
        {
            int stValue = 0;
            NSLog(@"getting status");
            [cValue getBytes:&stValue length:1];
            NSLog(@"got status");
            if (stValue==0) {
                res = @"Locked";
            } else if (stValue==1) {
                res = @"Unlocked";
            }
            //
            break;
        }
        default:
        {
            int cVal = 0;
            NSLog(@"getting default");
            [cValue getBytes:&cVal length:cValue.length];
            NSLog(@"got default");
            res = [NSString stringWithFormat:@"%i",cVal];
            break;
        }
    }
    //
    NSLog(@"got res: %@",res);
    //
    return res;
}

- (BOOL)setCharacteristicValue:(NSData *)value {
    if (!value) {
        return NO;
    }
    //
    CBCharacteristicWriteType writeType = CBCharacteristicWriteWithoutResponse;
    
    if (self.properties & CBCharacteristicPropertyWrite) {
        writeType = CBCharacteristicWriteWithResponse;
    } else if (self.properties & CBCharacteristicPropertyWriteWithoutResponse) {
        writeType = CBCharacteristicWriteWithoutResponse;
    }
    
    [self.service.peripheral writeValue:value forCharacteristic:self type:writeType];
    return YES;
}

-(void)logProperties {
    NSLog(@"|----\n%@",self.UUID);
    if (self.properties & CBCharacteristicPropertyBroadcast) {
        NSLog(@"CBCharacteristicPropertyBroadcast");
    }
    if (self.properties & CBCharacteristicPropertyRead) {
        NSLog(@"CBCharacteristicPropertyRead");
    }
    if (self.properties & CBCharacteristicPropertyWriteWithoutResponse) {
        NSLog(@"CBCharacteristicPropertyWriteWithoutResponse");
    }
    if (self.properties & CBCharacteristicPropertyWrite) {
        NSLog(@"CBCharacteristicPropertyWrite");
    }
    if (self.properties & CBCharacteristicPropertyNotify) {
        NSLog(@"CBCharacteristicPropertyNotify");
    }
    if (self.properties & CBCharacteristicPropertyIndicate) {
        NSLog(@"CBCharacteristicPropertyIndicate");
    }
    if (self.properties & CBCharacteristicPropertyAuthenticatedSignedWrites) {
        NSLog(@"CBCharacteristicPropertyAuthenticatedSignedWrites");
    }
    if (self.properties & CBCharacteristicPropertyExtendedProperties) {
        NSLog(@"CBCharacteristicPropertyExtendedProperties");
    }
    if (self.properties & CBCharacteristicPropertyNotifyEncryptionRequired) {
        NSLog(@"CBCharacteristicPropertyNotifyEncryptionRequired");
    }
    if (self.properties & CBCharacteristicPropertyIndicateEncryptionRequired) {
        NSLog(@"CBCharacteristicPropertyIndicateEncryptionRequired");
    }
    NSLog(@"-----");
}

#pragma mark - Internal methods

- (uint16_t)swappedIdentifier {
    uint16_t cIdentifier;
    if (self.UUID.data.length==2) {
        [self.UUID.data getBytes:&cIdentifier length:2];
    } else {
        NSLog(@"!!! size is %i",self.UUID.data.length);
        return 0;
    }
    return CFSwapInt16(cIdentifier);
}

@end
