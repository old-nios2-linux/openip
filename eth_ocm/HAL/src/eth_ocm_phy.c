#include "eth_ocm_phy.h"
#include <stdio.h>

static int eth_ocm_wait(int base);

void eth_ocm_set_phy_addr(int base, int phyad, int reg){
    phyad &= ETH_OCM_MIIADDRESS_FIAD_MSK; 
    reg = reg << ETH_OCM_MIIADDRESS_RGAD_OFST; 
    reg &= ETH_OCM_MIIADDRESS_RGAD_MSK;
    phyad |= reg;
    IOWR_ETH_OCM_MIIADDRESS(base, phyad); 
}

void eth_ocm_write_phy_reg(int base, int phyad, int reg, int data){
    eth_ocm_set_phy_addr(base, phyad, reg);
    IOWR_ETH_OCM_MIITX_DATA(base, data);
    IOWR_ETH_OCM_MIICOMMAND(base, ETH_OCM_MIICOMMAND_WCTRLDATA_MSK);
    eth_ocm_wait(base);
}

int  eth_ocm_read_phy_reg(int base, int phyad, int reg){
    int result;

    eth_ocm_set_phy_addr(base, phyad, reg);
    IOWR_ETH_OCM_MIICOMMAND(base, ETH_OCM_MIICOMMAND_RSTAT_MSK);
    eth_ocm_wait(base);
    result = IORD_ETH_OCM_MIIRX_DATA(base);
    return result;
}

static int eth_ocm_wait(int base){
    int temp;
    int i;
    i = 0;
    temp = 1;
    while(temp && i<1000){
        temp = IORD_ETH_OCM_MIISTATUS(base);
        if(temp & ETH_OCM_MIISTATUS_NVALID_MSK)
            printf("Invalid bit set in MII Status register\n");
        temp &= ETH_OCM_MIISTATUS_BUSY_MSK;
        i++;
    }
    if(i == 1000)
        printf("[eth_ocm_set_phy_reg] Failed waiting for MII module to be ready!\n");
        
    return temp;
    
}

#ifdef ETH_OCM_USE_INTERNAL_PHY_INIT
/**
 * Performs PHY initialization and determines link duplex.
 * This is fully vendor specific depending on the PHY you are using.
 *
 * @param  dev Pointer to eth_ocm_dev struct which contains needed base address
 * @return 1 if Link is established in Full duplex.
 *         0 if Link is established in Half duplex.
 */
int eth_ocm_phy_init(eth_ocm_dev *dev){
    int duplex;     /* 1 = full ; 0 = half*/
    int phyid;
    int phyid2;
    int dat;
    int phyadd;
    int base;
    int found;
    // determine PHY speed: This is PHY dependent and you need to change
    // this according to your PHY's specifications
    duplex = 1;
    dat = 0;
    phyadd = 0;
    found = 0;
    base = dev->base;

    // ------------------------------
    // PHY detection
    // ------------------------------
    phyid = eth_ocm_read_phy_reg(base, dat, ETH_OCM_PHY_ADDR_PHY_ID1);
    for (dat = 0x00; dat < 0xff; dat++){
        phyid = eth_ocm_read_phy_reg(base, dat, ETH_OCM_PHY_ADDR_PHY_ID1);
        phyid2 = eth_ocm_read_phy_reg(base, dat, ETH_OCM_PHY_ADDR_PHY_ID2);

        if (phyid != phyid2 && (phyid2 != 0xffff)){
            printf("[eth_ocm_phy_init] PHY ID 0x%x %x %x\n", dat, phyid, phyid2);
            phyadd = dat;
            dat = 0xff;
        }
    }

    #ifdef ETH_OCM_PHYID_LXT972A
    // ********************
    // Intel LXT972A 10/100
    // ********************
    if((phyid == (ETH_OCM_PHYID_LXT972A >> 16)) && (phyid2 == (ETH_OCM_PHYID_LXT972A & 0xFFFF))) {
        found = 1;
        printf("[eth_ocm_phy_init] Found LXT972A PHY\n");
        dat = eth_ocm_read_phy_reg(base, phyadd, ETH_OCM_PHY_ADDR_ADV);
        printf("[eth_ocm_phy_init] LXT972A Auto-neg capabilities: 0x%x\n",dat);
    }else{
        printf("[eth_ocm_phy_init] LXT972A NOT FOUND!\n");
    }
    #endif

    #ifdef ETH_OCM_PHYID_MVL
    // ***************
    // Marvell 88E1111
    // ***************
    if (phyid == ETH_OCM_PHYID_MVL){
        found = 1;
        printf("[eth_ocm_phy_init] Found Marvell 88E1111 PHY.\n");
        // Disable 1000BASE-T Autonegotiation
        dat = eth_ocm_read_phy_reg(base, phyadd, 0x09);
        dat &= 0xFCFF;
        eth_ocm_write_phy_reg(base, phyadd, 0x09, dat);    
        // Restart autonegotiation
        dat = eth_ocm_read_phy_reg(base, phyadd, ETH_OCM_PHY_ADDR_CONTROL);
        dat |=  PCS_CTL_an_restart;
        eth_ocm_write_phy_reg(base, phyadd, ETH_OCM_PHY_ADDR_CONTROL, dat);
    }
    else{
        printf("[eth_ocm_phy_init] Marvell 88E1111 not found!\n");
    }
    #endif //ifdef ETH_OCM_PHYID_MVL
    
    #ifdef ETH_OCM_PHYID_DP83848C
    // *****************
    // National DP83848C
    // *****************
    if((phyid == (ETH_OCM_PHYID_DP83848C >> 16)) && (phyid2 == (ETH_OCM_PHYID_DP83848C  & 0xFFFF))) {
        found = 1;
        printf("[eth_ocm_phy_init] Found DP83848C PHY\n");
        dat = eth_ocm_read_phy_reg(base, phyadd, ETH_OCM_PHY_ADDR_ADV);
        printf("[eth_ocm_phy_init] DP83848C Auto-neg capabilities: 0x%x\n",dat);
    }else{
        printf("[eth_ocm_phy_init] DP83848C PHY NOT FOUND!\n");
    }
    #endif // ifdef ETH_OCM_PHYID_DP83848C

    if(!found){
        printf("[eth_ocm_phy_init] No PHY found!\n");
        return 0;
    }
    // Issue a PHY reset here and wait for the link
    // autonegotiation complete again... this takes several SECONDS(!)
    // so be very careful not to do it frequently

    // perform this when PHY is configured in loopback or has no link yet.
    if( ((eth_ocm_read_phy_reg(base, phyadd, ETH_OCM_PHY_ADDR_CONTROL)& PCS_CTL_rx_slpbk) != 0) ||
         ((eth_ocm_read_phy_reg(base, phyadd, ETH_OCM_PHY_ADDR_STATUS) & PCS_ST_an_done) == 0) ) {
        eth_ocm_write_phy_reg(base, phyadd, ETH_OCM_PHY_ADDR_CONTROL,PCS_CTL_an_enable | PCS_CTL_sw_reset);    // send PHY reset command
        dprintf("[eth_ocm_phy_init] PHY Reset\n" );
    }
    
    if(!(eth_ocm_read_phy_reg(base, phyadd, ETH_OCM_PHY_ADDR_STATUS)& PCS_ST_an_done)) {
        printf("[eth_ocm_phy_init] Waiting on PHY link...");
        dat=0;
        while( (eth_ocm_read_phy_reg(base, phyadd, ETH_OCM_PHY_ADDR_STATUS) & PCS_ST_an_done) == 0 ){
            if( dat++ > ETH_OCM_PHY_TIMEOUT_THRESHOLD) {
                printf(" Autoneg FAILED, continuing anyway ...\n");
                break;
            }
        }
        printf("OK. x=%d, PHY STATUS=%04x\n",dat, eth_ocm_read_phy_reg(base, phyadd, ETH_OCM_PHY_ADDR_STATUS));
    }

    #ifdef ETH_OCM_PHYID_LXT972A
    // ********************
    // Intel LXT972A 10/100
    // ********************
    
    if((phyid == (ETH_OCM_PHYID_LXT972A >> 16)) && (phyid2 == (ETH_OCM_PHYID_LXT972A & 0xFFFF))) {
        // retrieve link speed from PHY
        dat = eth_ocm_read_phy_reg(base, phyadd, 0x11);
        duplex = (dat >> 9) & 0x01;
    }

    // End Intel LXT972A
    #endif //ifdef ETH_OCM_PHYID_LXT972A

    #ifdef ETH_OCM_PHYID_MVL
    // ***************
    // Marvell 88E1111
    // ***************
    if (phyid == ETH_OCM_PHYID_MVL){
        dat = eth_ocm_read_phy_reg(base, phyadd, 0x11);

        //duplex bit is not valid until resolved bit is set
        while(!(dat & (1 << 11)))
            dat = eth_ocm_read_phy_reg(base, phyadd, 0x11);

        duplex = (dat >> 13) & 0x01;
        if(dat & (1 << 14))
            printf("[eth_ocm_phy_init] WARNING: PHY operating in Gigabit mode\n");
    }
    // End Marvel 88E1111
    #endif // ifdef ETH_OCM_PHY_ID_MVL

    #ifdef ETH_OCM_PHYID_DP83848C
    // *****************
    // National DP83848C
    // *****************
    if((phyid == (ETH_OCM_PHYID_DP83848C >> 16)) && (phyid2 == (ETH_OCM_PHYID_DP83848C  & 0xFFFF))) {
        dat = eth_ocm_read_phy_reg(base, phyadd, 0x10);
        duplex = (dat >> 2) & 0x01;
    }
    #endif

    dprintf("[eth_ocm_phy_init] Full Duplex is %d\n", duplex);
    return duplex;
}
#endif // ifdef ETH_OCM_USE_INTERNAL_PHY_INIT

