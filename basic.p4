/* -*- P4_16 -*- */

// Tong Pow (84233063)
// James Xue (51632014)

#include <core.p4>
#include <v1model.p4>


typedef bit<48> macAddr_t;
typedef bit<9>  portId_t;

/*************************************************************************
*********************** H E A D E R S  ***********************************
*************************************************************************/

header ethernet_t {
    macAddr_t dstAddr;
    macAddr_t srcAddr;
    bit<16>   etherType;
}

header ipv4_t {
    // TODO
}

header arp_t {
    // TODO
}

struct cis553_metadata_t {
    // TODO
    bit<1> forMe;
}

struct headers_t {
    ethernet_t  ethernet;
    ipv4_t      ipv4;
    arp_t       arp;
}

/*************************************************************************
***********************  P A R S E   P A C K E T *************************
*************************************************************************/

parser cis553Parser(packet_in packet,
                    out headers_t parsed_header,
                    inout cis553_metadata_t metadata,
                    inout standard_metadata_t standard_metadata) {

    state start {
        transition parse_ethernet;
    }

    state parse_ethernet {
        // TODO
        packet.extract(parsed_header.ethernet);
        transition select(parsed_header.ethernet.etherType) {
            default: accept;
        }
    }
}


/*************************************************************************
************   C H E C K S U M    V E R I F I C A T I O N   *************
*************************************************************************/

control cis553VerifyChecksum(inout headers_t hdr,
                             inout cis553_metadata_t meta) {
     apply { }
}


/*************************************************************************
***********************  I N G R E S S  **********************************
*************************************************************************/

control cis553Ingress(inout headers_t hdr,
                      inout cis553_metadata_t metadata,
                      inout standard_metadata_t standard_metadata) {
    action aiForMe() {
        metadata.forMe = 1;
    }

    action aiNotForMe() {
        metadata.forMe = 0;
    }

    table tiHandleEthernet {
        key = {
            hdr.ethernet.dstAddr : exact;
            standard_metadata.ingress_port : exact;
        }
        actions = {
            aiForMe;
            aiNotForMe;
        }

        default_action = aiNotForMe();
    }

    action aDrop() {
        mark_to_drop();
    }

    action aiForward(macAddr_t mac_sa, macAddr_t mac_da, portId_t egress_port) {
        // TODO
    }

    table tiIpv4Lpm {
        // TODO
    }

    action aiArpResponse(macAddr_t mac_sa) {
        // TODO
    }

    table tiArpResponse {
        // TODO
    }

    apply {
        tiHandleEthernet.apply();

        if (metadata.forMe == 0) {
            aDrop();
        } else if (hdr.ipv4.isValid()) {
            tiIpv4Lpm.apply();
        } else if (hdr.arp.isValid()) {
            tiArpResponse.apply();
        } else {
            aDrop();
        }
    }
}


/*************************************************************************
***********************  E G R E S S  ************************************
*************************************************************************/

control cis553Egress(inout headers_t hdr,
                     inout cis553_metadata_t metadata,
                     inout standard_metadata_t standard_metadata) {
    apply { }
}


/*************************************************************************
*************   C H E C K S U M    C O M P U T A T I O N   ***************
*************************************************************************/

control cis553ComputeChecksum(inout headers_t hdr,
                              inout cis553_metadata_t meta) {
    apply {
        update_checksum(
            hdr.ipv4.isValid(),
            { 
                // TODO: fields to checksum
            },
            // TODO: checksum field
            ,
            HashAlgorithm.csum16);
    }
}

/*************************************************************************
****************  E G R E S S   P R O C E S S I N G   ********************
*************************************************************************/

control cis553Deparser(packet_out packet, in headers_t hdr) {
    apply {
        packet.emit(hdr.ethernet);
        packet.emit(hdr.arp);
        packet.emit(hdr.ipv4);
    }
}

/*************************************************************************
***********************  S W I T C H  ************************************
*************************************************************************/

V1Switch(cis553Parser(),
         cis553VerifyChecksum(),
         cis553Ingress(),
         cis553Egress(),
         cis553ComputeChecksum(),
         cis553Deparser()) main;
