import Test
@testable import TLS

let header: [UInt8] = [
    // handshake
    0x16,
    // tls 1.2
    0x03, 0x03,
    // length: 1556
    0x06, 0x14,
    // handshake type: certificate status
    0x16,
    // length: 1552
    0x00, 0x06, 0x10,
    // status type: ocsp
    0x01,
    // status length: 1548
    0x00, 0x06, 0x0c
]

let status: [UInt8] = [
    0x30, 0x82, 0x06,
    0x08, 0x0a, 0x01,
    // status
    0x00,
    // -
    0xa0, 0x82, 0x06, 0x01,
    // response bytes
    0x30, 0x82, 0x05, 0xfd, 0x06, 0x09, 0x2b, 0x06,
    0x01, 0x05, 0x05, 0x07, 0x30, 0x01, 0x01, 0x04,
    0x82, 0x05, 0xee, 0x30, 0x82, 0x05, 0xea, 0x30,
    0x82, 0x01, 0x02, 0xa0, 0x03, 0x02, 0x01, 0x00,
    0xa1, 0x57, 0x30, 0x55, 0x31, 0x0b, 0x30, 0x09,
    0x06, 0x03, 0x55, 0x04, 0x06, 0x13, 0x02, 0x50,
    0x4c, 0x31, 0x22, 0x30, 0x20, 0x06, 0x03, 0x55,
    0x04, 0x0a, 0x0c, 0x19, 0x55, 0x6e, 0x69, 0x7a,
    0x65, 0x74, 0x6f, 0x20, 0x54, 0x65, 0x63, 0x68,
    0x6e, 0x6f, 0x6c, 0x6f, 0x67, 0x69, 0x65, 0x73,
    0x20, 0x53, 0x2e, 0x41, 0x2e, 0x31, 0x22, 0x30,
    0x20, 0x06, 0x03, 0x55, 0x04, 0x03, 0x0c, 0x19,
    0x43, 0x65, 0x72, 0x74, 0x75, 0x6d, 0x20, 0x56,
    0x61, 0x6c, 0x69, 0x64, 0x61, 0x74, 0x69, 0x6f,
    0x6e, 0x20, 0x53, 0x65, 0x72, 0x76, 0x69, 0x63,
    0x65, 0x18, 0x0f, 0x32, 0x30, 0x31, 0x36, 0x31,
    0x30, 0x32, 0x37, 0x30, 0x30, 0x32, 0x34, 0x34,
    0x33, 0x5a, 0x30, 0x71, 0x30, 0x6f, 0x30, 0x47,
    0x30, 0x07, 0x06, 0x05, 0x2b, 0x0e, 0x03, 0x02,
    0x1a, 0x04, 0x14, 0xad, 0x9e, 0x23, 0x06, 0x7d,
    0xa8, 0x72, 0x59, 0x45, 0x83, 0x11, 0xe4, 0x8b,
    0x50, 0x56, 0xcd, 0x47, 0xd2, 0x4b, 0x02, 0x04,
    0x14, 0x37, 0x5c, 0xe3, 0x19, 0xe0, 0xb2, 0x8e,
    0xa1, 0xa8, 0x4e, 0xd2, 0xcf, 0xab, 0xd0, 0xdc,
    0xe3, 0x0b, 0x5c, 0x35, 0x4d, 0x02, 0x10, 0x62,
    0xfa, 0x7d, 0x18, 0x39, 0x8c, 0x6e, 0x14, 0xec,
    0x17, 0xc6, 0xfa, 0x50, 0x77, 0x75, 0xdf, 0x80,
    0x00, 0x18, 0x0f, 0x32, 0x30, 0x31, 0x36, 0x31,
    0x30, 0x32, 0x37, 0x30, 0x30, 0x32, 0x34, 0x34,
    0x33, 0x5a, 0xa0, 0x11, 0x18, 0x0f, 0x32, 0x30,
    0x31, 0x36, 0x31, 0x31, 0x30, 0x33, 0x30, 0x30,
    0x32, 0x34, 0x34, 0x33, 0x5a, 0xa1, 0x1e, 0x30,
    0x1c, 0x30, 0x1a, 0x06, 0x09, 0x2b, 0x06, 0x01,
    0x05, 0x05, 0x07, 0x30, 0x01, 0x04, 0x04, 0x0d,
    0x30, 0x0b, 0x06, 0x09, 0x2b, 0x06, 0x01, 0x05,
    0x05, 0x07, 0x30, 0x01, 0x01, 0x30, 0x0b, 0x06,
    0x09, 0x2a, 0x86, 0x48, 0x86, 0xf7, 0x0d, 0x01,
    0x01, 0x0b, 0x03, 0x82, 0x01, 0x01, 0x00, 0x34,
    0x20, 0xef, 0x14, 0x6d, 0xb1, 0xb5, 0xf5, 0x07,
    0xa0, 0x41, 0xb1, 0x5b, 0x47, 0x01, 0xa5, 0xcf,
    0x2e, 0x63, 0x12, 0x20, 0x7a, 0x7b, 0xae, 0x11,
    0xae, 0xd2, 0x76, 0xe4, 0x4a, 0x97, 0xac, 0x22,
    0x59, 0xd9, 0x9c, 0xd9, 0x2c, 0x39, 0x10, 0xb8,
    0x9d, 0x14, 0x78, 0x98, 0x50, 0x71, 0x02, 0xae,
    0x33, 0x91, 0xd4, 0x9b, 0x97, 0xb2, 0x70, 0xd0,
    0x0f, 0x31, 0x5f, 0x18, 0xc9, 0x1f, 0x3c, 0x68,
    0x71, 0x8f, 0x9a, 0x88, 0xac, 0xce, 0x74, 0x7c,
    0xe5, 0x9a, 0x9b, 0xe4, 0xac, 0x8c, 0xe9, 0xf5,
    0x43, 0x3c, 0x8d, 0x52, 0x0a, 0x70, 0x65, 0xe6,
    0xee, 0x30, 0x49, 0x19, 0x98, 0x1b, 0xc1, 0x84,
    0x51, 0xfd, 0x5e, 0xf4, 0x0a, 0x6c, 0x3b, 0xde,
    0xbb, 0x7a, 0xdb, 0x65, 0x11, 0x63, 0x32, 0xd4,
    0x9b, 0xf7, 0x21, 0x98, 0x37, 0x71, 0x7d, 0xa1,
    0xf5, 0xbb, 0xd5, 0xb7, 0xbe, 0xdc, 0x56, 0xae,
    0x0f, 0x20, 0xc0, 0xab, 0x9d, 0x1a, 0x27, 0x70,
    0x14, 0x58, 0x10, 0x29, 0x2e, 0xc9, 0x12, 0x0e,
    0x81, 0x6b, 0xfa, 0x12, 0xe3, 0x73, 0x3d, 0x18,
    0xfd, 0xd8, 0xe0, 0x6f, 0xbd, 0x49, 0x60, 0x38,
    0x6b, 0x48, 0xf5, 0x06, 0xde, 0xee, 0xba, 0xca,
    0x4a, 0x48, 0x0b, 0x31, 0x65, 0x0a, 0xd3, 0x67,
    0xd3, 0xbb, 0x11, 0x5c, 0x7f, 0xdc, 0x8d, 0xeb,
    0x24, 0x1e, 0x08, 0xc9, 0x79, 0x0a, 0x48, 0x2e,
    0xf5, 0xe4, 0xcd, 0xaa, 0x4b, 0x3b, 0x45, 0xc9,
    0xb6, 0x73, 0x49, 0xcc, 0x7d, 0x02, 0xdc, 0x6e,
    0x23, 0xbc, 0x55, 0x0e, 0x07, 0xdb, 0x28, 0xbf,
    0xa7, 0xf5, 0x2f, 0xcc, 0x85, 0xb0, 0xdc, 0x9f,
    0x30, 0x1f, 0x9f, 0xb5, 0xe4, 0x30, 0x7d, 0x8a,
    0x53, 0x92, 0x2e, 0xe6, 0x71, 0x8d, 0xe4, 0xbb,
    0x58, 0xf5, 0x63, 0xd9, 0x51, 0x9d, 0x4b, 0xff,
    0xf2, 0x46, 0xd5, 0x6a, 0xa9, 0x0e, 0xcf, 0xa0,
    0x82, 0x03, 0xce, 0x30, 0x82, 0x03, 0xca, 0x30,
    0x82, 0x03, 0xc6, 0x30, 0x82, 0x02, 0xae, 0xa0,
    0x03, 0x02, 0x01, 0x02, 0x02, 0x10, 0x75, 0xb6,
    0x69, 0x45, 0x9b, 0xad, 0x8d, 0xda, 0xed, 0xc4,
    0xf7, 0xf6, 0xf6, 0xd6, 0xa8, 0x2c, 0x30, 0x0d,
    0x06, 0x09, 0x2a, 0x86, 0x48, 0x86, 0xf7, 0x0d,
    0x01, 0x01, 0x0b, 0x05, 0x00, 0x30, 0x5f, 0x31,
    0x0b, 0x30, 0x09, 0x06, 0x03, 0x55, 0x04, 0x06,
    0x13, 0x02, 0x52, 0x55, 0x31, 0x13, 0x30, 0x11,
    0x06, 0x03, 0x55, 0x04, 0x0a, 0x13, 0x0a, 0x59,
    0x61, 0x6e, 0x64, 0x65, 0x78, 0x20, 0x4c, 0x4c,
    0x43, 0x31, 0x27, 0x30, 0x25, 0x06, 0x03, 0x55,
    0x04, 0x0b, 0x13, 0x1e, 0x59, 0x61, 0x6e, 0x64,
    0x65, 0x78, 0x20, 0x43, 0x65, 0x72, 0x74, 0x69,
    0x66, 0x69, 0x63, 0x61, 0x74, 0x69, 0x6f, 0x6e,
    0x20, 0x41, 0x75, 0x74, 0x68, 0x6f, 0x72, 0x69,
    0x74, 0x79, 0x31, 0x12, 0x30, 0x10, 0x06, 0x03,
    0x55, 0x04, 0x03, 0x13, 0x09, 0x59, 0x61, 0x6e,
    0x64, 0x65, 0x78, 0x20, 0x43, 0x41, 0x30, 0x1e,
    0x17, 0x0d, 0x31, 0x36, 0x30, 0x38, 0x31, 0x30,
    0x31, 0x30, 0x33, 0x36, 0x32, 0x37, 0x5a, 0x17,
    0x0d, 0x31, 0x36, 0x31, 0x31, 0x30, 0x38, 0x31,
    0x30, 0x33, 0x36, 0x32, 0x37, 0x5a, 0x30, 0x55,
    0x31, 0x0b, 0x30, 0x09, 0x06, 0x03, 0x55, 0x04,
    0x06, 0x13, 0x02, 0x50, 0x4c, 0x31, 0x22, 0x30,
    0x20, 0x06, 0x03, 0x55, 0x04, 0x0a, 0x0c, 0x19,
    0x55, 0x6e, 0x69, 0x7a, 0x65, 0x74, 0x6f, 0x20,
    0x54, 0x65, 0x63, 0x68, 0x6e, 0x6f, 0x6c, 0x6f,
    0x67, 0x69, 0x65, 0x73, 0x20, 0x53, 0x2e, 0x41,
    0x2e, 0x31, 0x22, 0x30, 0x20, 0x06, 0x03, 0x55,
    0x04, 0x03, 0x0c, 0x19, 0x43, 0x65, 0x72, 0x74,
    0x75, 0x6d, 0x20, 0x56, 0x61, 0x6c, 0x69, 0x64,
    0x61, 0x74, 0x69, 0x6f, 0x6e, 0x20, 0x53, 0x65,
    0x72, 0x76, 0x69, 0x63, 0x65, 0x30, 0x82, 0x01,
    0x22, 0x30, 0x0d, 0x06, 0x09, 0x2a, 0x86, 0x48,
    0x86, 0xf7, 0x0d, 0x01, 0x01, 0x01, 0x05, 0x00,
    0x03, 0x82, 0x01, 0x0f, 0x00, 0x30, 0x82, 0x01,
    0x0a, 0x02, 0x82, 0x01, 0x01, 0x00, 0x9a, 0x1e,
    0x26, 0x40, 0x02, 0x4c, 0x29, 0x3d, 0x44, 0x62,
    0x53, 0xb4, 0x34, 0x8e, 0xa0, 0x1c, 0x76, 0xa1,
    0x2e, 0xb0, 0x10, 0x98, 0x76, 0xea, 0xb2, 0x55,
    0x9b, 0x1d, 0xc9, 0x31, 0x56, 0x66, 0x86, 0xb9,
    0x8d, 0x02, 0xec, 0x36, 0x66, 0x9c, 0x68, 0x1e,
    0x04, 0x48, 0x56, 0x4c, 0x58, 0x66, 0xbd, 0xe9,
    0x5a, 0x2c, 0xbb, 0x56, 0x93, 0x34, 0xf3, 0x62,
    0xee, 0x65, 0xdc, 0xd5, 0x95, 0x4a, 0xb9, 0xf1,
    0xe6, 0x27, 0x99, 0x74, 0xa6, 0xc4, 0x12, 0x42,
    0x1b, 0xa4, 0x76, 0xb7, 0xa3, 0xce, 0x65, 0x15,
    0x76, 0x37, 0x07, 0xfa, 0x6d, 0xbf, 0xf0, 0x4c,
    0x06, 0xb4, 0x7c, 0x9e, 0x5f, 0x9e, 0xa7, 0xba,
    0xc3, 0x71, 0x64, 0xcd, 0xa8, 0x4a, 0x55, 0x16,
    0x9d, 0x18, 0x1f, 0x17, 0x2b, 0x58, 0x7e, 0x0c,
    0x3d, 0x75, 0xbc, 0x85, 0xd2, 0xd7, 0xae, 0x81,
    0x5b, 0x1e, 0xd7, 0x54, 0xb7, 0x9e, 0x58, 0x3e,
    0x2b, 0x8b, 0x5c, 0x79, 0x15, 0x5c, 0x45, 0x85,
    0x19, 0xb7, 0x96, 0xb6, 0x8c, 0x0c, 0xfb, 0xb0,
    0xf7, 0x29, 0xb4, 0x2d, 0x60, 0x77, 0x76, 0xa8,
    0x29, 0x04, 0x14, 0xb2, 0xc6, 0x38, 0x6a, 0xd2,
    0xa5, 0xeb, 0x39, 0x48, 0x03, 0x9f, 0x08, 0x42,
    0x2d, 0x43, 0x95, 0x17, 0xb3, 0x3e, 0x49, 0x56,
    0x36, 0xd1, 0xf4, 0x93, 0xd0, 0xcc, 0x8a, 0x61,
    0xb6, 0xdf, 0xf1, 0x9c, 0xd3, 0xc7, 0xa6, 0x79,
    0xac, 0x3c, 0x05, 0x97, 0x71, 0x4a, 0x2c, 0x7f,
    0xc4, 0x23, 0x48, 0x6e, 0xea, 0x34, 0xbc, 0xbc,
    0xac, 0x7d, 0x3d, 0xd6, 0x26, 0xa1, 0x5a, 0x41,
    0x11, 0x18, 0xb8, 0x03, 0xbb, 0xc2, 0xbd, 0x5b,
    0xe1, 0x83, 0x4d, 0xba, 0xe1, 0x6a, 0x69, 0x1c,
    0xd6, 0xe2, 0x6e, 0x16, 0x14, 0x8a, 0xac, 0x5a,
    0x4c, 0xe2, 0xba, 0xc5, 0x93, 0x61, 0x67, 0x21,
    0x8f, 0xfc, 0x7c, 0x14, 0xf7, 0x99, 0x02, 0x03,
    0x01, 0x00, 0x01, 0xa3, 0x81, 0x87, 0x30, 0x81,
    0x84, 0x30, 0x0c, 0x06, 0x03, 0x55, 0x1d, 0x13,
    0x01, 0x01, 0xff, 0x04, 0x02, 0x30, 0x00, 0x30,
    0x1f, 0x06, 0x03, 0x55, 0x1d, 0x23, 0x04, 0x18,
    0x30, 0x16, 0x80, 0x14, 0x37, 0x5c, 0xe3, 0x19,
    0xe0, 0xb2, 0x8e, 0xa1, 0xa8, 0x4e, 0xd2, 0xcf,
    0xab, 0xd0, 0xdc, 0xe3, 0x0b, 0x5c, 0x35, 0x4d,
    0x30, 0x1d, 0x06, 0x03, 0x55, 0x1d, 0x0e, 0x04,
    0x16, 0x04, 0x14, 0x27, 0x32, 0xf5, 0x7a, 0x62,
    0x6e, 0x37, 0x67, 0xb1, 0x57, 0x91, 0x67, 0xa6,
    0xdd, 0x46, 0xb9, 0x5d, 0x5c, 0xe0, 0x5a, 0x30,
    0x0e, 0x06, 0x03, 0x55, 0x1d, 0x0f, 0x01, 0x01,
    0xff, 0x04, 0x04, 0x03, 0x02, 0x06, 0xc0, 0x30,
    0x13, 0x06, 0x03, 0x55, 0x1d, 0x25, 0x04, 0x0c,
    0x30, 0x0a, 0x06, 0x08, 0x2b, 0x06, 0x01, 0x05,
    0x05, 0x07, 0x03, 0x09, 0x30, 0x0f, 0x06, 0x09,
    0x2b, 0x06, 0x01, 0x05, 0x05, 0x07, 0x30, 0x01,
    0x05, 0x04, 0x02, 0x05, 0x00, 0x30, 0x0d, 0x06,
    0x09, 0x2a, 0x86, 0x48, 0x86, 0xf7, 0x0d, 0x01,
    0x01, 0x0b, 0x05, 0x00, 0x03, 0x82, 0x01, 0x01,
    0x00, 0x06, 0x70, 0xf2, 0xc0, 0x93, 0xfd, 0xac,
    0x68, 0x75, 0xe3, 0xf3, 0x6c, 0xa8, 0xe7, 0xb6,
    0x6b, 0xd3, 0x1e, 0xe9, 0x3b, 0x29, 0xfb, 0xda,
    0xe2, 0xc0, 0x6d, 0x05, 0xb6, 0x34, 0xb0, 0x2a,
    0xae, 0x17, 0x55, 0x4d, 0x86, 0x39, 0x28, 0x24,
    0xb5, 0xa7, 0xc3, 0x01, 0x96, 0x4a, 0xbe, 0xd5,
    0x3f, 0xc5, 0x47, 0x65, 0x64, 0xd8, 0x93, 0x8f,
    0x4a, 0x11, 0xaf, 0x70, 0x96, 0xe5, 0x09, 0x4a,
    0xbf, 0xd7, 0x1f, 0x26, 0x83, 0x54, 0x08, 0x4b,
    0x2b, 0x0f, 0x5f, 0x5a, 0x2c, 0x1e, 0xb6, 0xdf,
    0xc2, 0xe8, 0xe3, 0x97, 0xab, 0x1b, 0x7b, 0xa9,
    0xf8, 0xdf, 0x92, 0xb1, 0x56, 0x58, 0x1d, 0xe4,
    0x94, 0x92, 0x29, 0x3f, 0x72, 0x8b, 0x63, 0x1a,
    0x31, 0x5a, 0x3c, 0xfb, 0x09, 0x53, 0xb8, 0x71,
    0x52, 0xc7, 0xdc, 0xb4, 0x71, 0x16, 0x7c, 0xd8,
    0x95, 0x3c, 0xda, 0x3d, 0xa3, 0xe6, 0xb8, 0xb2,
    0x4f, 0x22, 0x69, 0x95, 0x04, 0x16, 0x26, 0x37,
    0xfe, 0xe6, 0xa8, 0x67, 0x6e, 0x00, 0x1f, 0x8f,
    0xb0, 0xd1, 0x2f, 0x70, 0xf5, 0x13, 0xec, 0x52,
    0x69, 0xb6, 0xa4, 0x44, 0x0f, 0xd8, 0x6e, 0x57,
    0x3b, 0x85, 0xe5, 0x53, 0xa8, 0xb4, 0xf6, 0x33,
    0xb9, 0x64, 0x8d, 0x9f, 0xfc, 0x70, 0x3b, 0x6f,
    0xdb, 0xe3, 0xac, 0xbc, 0xed, 0x66, 0xe5, 0x13,
    0xe5, 0xe2, 0xd4, 0x25, 0x30, 0x0f, 0x3c, 0x0c,
    0xfa, 0xf6, 0xee, 0x98, 0x9d, 0xc8, 0x0a, 0xbd,
    0x83, 0x8e, 0xdb, 0xf5, 0x88, 0xe7, 0xeb, 0xa8,
    0xad, 0x52, 0x84, 0x85, 0x9d, 0x1d, 0x74, 0xae,
    0x16, 0xec, 0x75, 0x5e, 0x9f, 0x04, 0x7c, 0xee,
    0xb3, 0xab, 0x4b, 0xc2, 0xcc, 0x73, 0xfe, 0xe6,
    0xe3, 0x6d, 0xd7, 0xc7, 0x6b, 0xcb, 0xf6, 0x40,
    0xaf, 0x0c, 0xbb, 0xbf, 0x2e, 0xaf, 0x93, 0x28,
    0x49, 0x71, 0x95, 0x27, 0x3f, 0x6c, 0xf9, 0x76,
    0x65]

let bytes: [UInt8] = header + status

test("Decode") {
//    let recordLayer = try await RecordLayer.decode(from: bytes)

//    switch recordLayer.content {
//    case .handshake(.certificateStatus(.ocsp(let response))):
//        expect(response.status == .success)
//        // TODO:
//        // expect(response.basicResponse == ...)
//    default:
//        fail()
//    }
}

await run()
