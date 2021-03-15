/*--------------------------------------------------------------------------------------------------
Project               : TOKENUP

IPBrief TESTID: TokenUp.SysTS-394

Owner         : 

Command to run this test:
        make run_uvm uvm_test=TokenUp_SysTS_394 iuo="+define+PACKAGE_OPTION_ACTICUP +define+PACKAGE_OPTION_XT32_DISCON" &

TEST DESCRIPTION:
Test GPIO configuration as input or output

Test procedure
  boot
  check that each port is configured as input by default,
  toggle the input and check if it is correctly captured by the device
  configure device port as output
  drive output:
  test both cases:
  - "low"
  - "high"
  repeat for each I/O

SEQUENCE:
  1. Boot IC.
  2. Randomized internal variables
  3. Entering monitor mode by using enterDebug task
  4. Check default values by reading each port and check with assertion PxDIR = 0x00
  5. Configure PxDIR, PxOUT register and testbench's GPIO interface based on randomized value at
     step 2
  6. Check if the configuration of PxDIR, PxOUT register and testbench's GPIO are correct
  7. Read PxINS register and then check if the input is correctly captured by the device and
     check if the output is correctly set by the device

--------------------------------------------------------------------------------------------------*/

// `define Port1Ins `CORE_PATH.dig_top.Iw8Port1In //`CORE_PATH.dig_top.digfunc_top.port.Iw8Port1In
// `define Port2Ins `CORE_PATH.dig_top.Iw8Port2In
// `define Port3Ins `CORE_PATH.dig_top.Iw6Port3In

typedef reg[7:0]    uint8;
typedef reg[31:0]   uint32;

// define macro for RTL

`define RTLWrite_RegDir				`ANA_TB_PATH.MDI.dbgSetDataByte//	
`define RTLRead_RegDir				`ANA_TB_PATH.MDI.dbgGetDataByte//	 			

`define RTLWrite_RegWrite			`ANA_TB_PATH.MDI.dbgSetDataByte//	
`define RTLRead_RegRead				`ANA_TB_PATH.MDI.dbgGetDataByte//				

// define macro for Vir
`define VIRWrite_RegDir		 		`ANA_TB_PATH.GPIO.dbgSetDataByte//
`define VIRWrite_RegWrite			`ANA_TB_PATH.GPIO.dbgSetDataByte//

`define VIRRead_RegRead				`ANA_TB_PATH.GPIO.dbgGetDataByte//


// define macro address of registers (RTL and Virtual)
// for RTL GPIO1: 8 bit                                                   
`define RTL_AddrGPIO1_Direction		`P1DIR	// register 8 bits 	           
`define RTL_AddrGPIO1_RegRead		`P1INS	// register 8 bits 		            
`define RTL_AddrGPIO1_RegWrite		`P1OUT	// register 8 bits 			          
// for Vir GPIO1: 8 bit                                                   
`define Vir_AddrGPIO1_Direction		`P1DIR	// register 8 bits             
`define Vir_AddrGPIO1_RegRead		`P1INS	// register 8 bits 			     
`define Vir_AddrGPIO1_RegWrite		`P1OUT	// register 8 bits 	         

// for RTL GPIO2: 8 bit                                                   
`define RTL_AddrGPIO2_Direction		`P2DIR	// register 8 bits 	           
`define RTL_AddrGPIO2_RegRead		`P2INS	// register 8 bits 		            
`define RTL_AddrGPIO2_RegWrite		`P2OUT	// register 8 bits 			          
// for Vir GPIO2: 8 bit                                                   
`define Vir_AddrGPIO2_Direction		`P2DIR	// register 8 bits       
`define Vir_AddrGPIO2_RegRead		`P2INS	// register 8 bits 		   
`define Vir_AddrGPIO2_RegWrite		`P2OUT	// register 8 bits 	   

// for RTL GPIO3: 8 bit                                                   
`define RTL_AddrGPIO3_Direction		`P3DIR	// register 8 bits 	           
`define RTL_AddrGPIO3_RegRead		`P3INS	// register 8 bits 		            
`define RTL_AddrGPIO3_RegWrite		`P3OUT	// register 8 bits 	            
// for Vir GPIO3: 8 bit                                                   
`define Vir_AddrGPIO3_Direction		`P3DIR	// register 8 bits    
`define Vir_AddrGPIO3_RegRead		`P3INS	// register 8 bits 		
`define Vir_AddrGPIO3_RegWrite		`P3OUT	// register 8 bits 	
		
// init value of registers
`define GPIOSetup(dir, in, out)					\
    {                           				\
    dir,                        				\
    in,                         				\
    out                         				\
    } 
`define GPIOInit  GPIOSetup(0, 0, 0)  
`define dontcare 0
// check error
 typedef enum
    {
    NoError	= 0,
    Error	= 1
    }CheckStatus; 
// pin
 typedef enum
    {
    PinIsInput	= 0,
    PinIsOutput	= 1
    }DirPin; 
// port 8 bit 
 typedef enum
    {
    isInput		= 0,
    isOutput	= 255
    }DirType; 
typedef enum
    {
    Clear	= 0,
    Set		= 1
    }BitType; 	
typedef enum
    {
    DataisLow	= 0,
    DataisHigh	= 255
    }DataType;  
// define GPIO
typedef struct
    {
    uint8 Direction	;
    uint8 RegRead		;
    uint8 RegWrite		;
    }GPIO_TYPE; 
class RandomData;
	rand uint8 valuePort1;
	rand uint8 valuePort2;
	rand uint8 valuePort3;
	endclass
	
GPIO_TYPE RTL_GPIO1, RTL_GPIO2, RTL_GPIO3;
GPIO_TYPE Vir_GPIO1, Vir_GPIO2, Vir_GPIO3;
			
RandomData RandomData_Obj;

//==================================================================================================
//==================================================================================================

class TokenUp_SysTS_394_vseq extends top_base_mdi_vseq;

 `uvm_object_utils(TokenUp_SysTS_394_vseq)

	logic    [15:0]  status;

	reg      [7:0]   RTL_read_value_gpio1 = 0;
	reg      [7:0]   RTL_read_value_gpio2 = 0;
	reg      [7:0]   RTL_read_value_gpio3 = 0;

	reg      [7:0]   Vir_read_value_gpio1 = 0;
	reg      [7:0]   Vir_read_value_gpio2 = 0;
	reg      [7:0]   Vir_read_value_gpio3 = 0;	

	reg      [7:0]   data_random_gpio1    = 0;
	reg      [7:0]   data_random_gpio2    = 0;
	reg      [7:0]   data_random_gpio3    = 0;	
	reg      [7:0]   i = 0, Check = 0;	
	
  //------------------------------------------------------------------------------------------------
  
  function new (string name = "TokenUp_SysTS_394_vseq");
    super.new(name);

    //coverage
    //----------------------------------------------------------------------------------------------
    SYSTS_394_cg = new();
    SYSTS_394_cg.set_inst_name("SYSTS_394_CG");
    //----------------------------------------------------------------------------------------------
  endfunction : new

  virtual task body();		
    super.body();
    //----------------------------------------------------------------------------------------------

    //----------------------------------------------------------------------------------------------
    //coverage sample
    //----------------------------------------------------------------------------------------------
    
	
    //----------------------------------------------------------------------------------------------
    // Test sequence:
    //----------------------------------------------------------------------------------------------
    // 2. Power up IC.
    // 3. Entering monitor mode by using enterDebug task
    //----------------------------------------------------------------------------------------------
    //DoPowerUp();
    `ANA_TB_PATH.MDI.enterDebug();
    `ANA_TB_PATH.MDI.dbgSetBaudRate(3);

	 
    //----------------------------------------------------------------------------------------------
	 // 1. Check that each port is configured as input by default
	 `uvm_info("DUT",$sformatf("1. Check that each port is configured as input by default"), UVM_LOW);	
	 
	 RTLRead_RegDir (RTL_AddrGPIO1_Direction, RTL_read_value_gpio1, status); 
	 RTLRead_RegDir (RTL_AddrGPIO2_Direction, RTL_read_value_gpio2, status); 
	 RTLRead_RegDir (RTL_AddrGPIO3_Direction, RTL_read_value_gpio3, status); 
	 
	 if((RTL_read_value_gpio1 == isInput) && (RTL_read_value_gpio2 == isInput) && (RTL_read_value_gpio3 == isInput)) begin
		 `uvm_info( get_type_name(), $sformatf( "\n\n *** Pass unit 1. Check that each port is configured as input by default ***\n\n" ), UVM_LOW);
		 end
	 else begin
		`uvm_error(get_type_name(), "** UVM TEST FAIL **");
		 end 
 	
	//2. Random input, output
	
	RandomData_Obj = new();
	repeat(255) begin
		//
		if(RandomData_Obj.randomize()) begin
		data_random_gpio1 = RandomData_Obj.valuePort1;
		data_random_gpio2 = RandomData_Obj.valuePort2;
		data_random_gpio3 = RandomData_Obj.valuePort3;
		//
		RTL_GPIO1 = GPIOSetup(data_random_gpio1, dontcare, dontcare);
		RTL_GPIO2 = GPIOSetup(data_random_gpio2, dontcare, dontcare);
		RTL_GPIO3 = GPIOSetup(data_random_gpio3, dontcare, dontcare);
		//
		Vir_GPIO1 = GPIOSetup(~data_random_gpio1, dontcare, dontcare);
		Vir_GPIO2 = GPIOSetup(~data_random_gpio2, dontcare, dontcare);
		Vir_GPIO3 = GPIOSetup(~data_random_gpio3, dontcare, dontcare);
		// setting dir for RTL mudule
		RTLWrite_RegDir (RTL_AddrGPIO1_Direction, RTL_GPIO1.Direction, status); 
		RTLWrite_RegDir (RTL_AddrGPIO2_Direction, RTL_GPIO2.Direction, status); 
		RTLWrite_RegDir (RTL_AddrGPIO3_Direction, RTL_GPIO3.Direction, status); 
		// setting dir for Virtual module
		VIRWrite_RegDir (Vir_AddrGPIO1_Direction, Vir_GPIO1.Direction, status); 
		VIRWrite_RegDir (Vir_AddrGPIO2_Direction, Vir_GPIO2.Direction, status); 
		VIRWrite_RegDir (Vir_AddrGPIO3_Direction, Vir_GPIO3.Direction, status); 			
		end 
		
		// ===================================================================
		// port 1, 2, 3 ------------------------------------------------------
		// rtl that pins is input, ignore output
		VIRWrite_RegWrite (Vir_AddrGPIO1_RegWrite, data_random_gpio1, status); 
		VIRWrite_RegWrite (Vir_AddrGPIO2_RegWrite, data_random_gpio2, status); 
		VIRWrite_RegWrite (Vir_AddrGPIO3_RegWrite, data_random_gpio3, status); 		
		#5us;
		//
		RTLRead_RegRead (RTL_AddrGPIO1_RegRead, RTL_read_value_gpio1, status); 
		RTLRead_RegRead (RTL_AddrGPIO2_RegRead, RTL_read_value_gpio2, status); 
		RTLRead_RegRead (RTL_AddrGPIO3_RegRead, RTL_read_value_gpio3, status); 
		//	
		Check = 0;
		for(i = 0; i < 8; i++) begin
			if(data_random_gpio1[i:i] == PinIsInput) begin
				if(RTL_read_value_gpio1[i:i] != data_random_gpio1[i:i]) begin
				Check = Error; break;
				end 
			end 
			if(data_random_gpio2[i:i] == PinIsInput) begin
				if(RTL_read_value_gpio2[i:i] != data_random_gpio2[i:i]) begin
				Check = Error; break;
				end 
			end
			if(data_random_gpio3[i:i] == PinIsInput) begin
				if(RTL_read_value_gpio3[i:i] != data_random_gpio3[i:i]) begin
				Check = Error; break;
				end 
			end 			
			end 
		if(Check == NoError) begin
			`uvm_info( get_type_name(), $sformatf( "\n\n *** ok, line 302 ***\n\n"), UVM_LOW);
			end
		else begin
			`uvm_error(get_type_name(), "** UVM TEST Fail, line 305 **");
			end 		

			
		// rtl that pins is out, ignore input
		RTLWrite_RegWrite (RTL_AddrGPIO1_RegWrite, data_random_gpio1, status); 
		RTLWrite_RegWrite (RTL_AddrGPIO2_RegWrite, data_random_gpio2, status); 
		RTLWrite_RegWrite (RTL_AddrGPIO3_RegWrite, data_random_gpio3, status); 		
		#5us;
		//
		VIRRead_RegRead (Vir_AddrGPIO1_RegRead, Vir_read_value_gpio1, status); 
		VIRRead_RegRead (Vir_AddrGPIO2_RegRead, Vir_read_value_gpio2, status); 
		VIRRead_RegRead (Vir_AddrGPIO3_RegRead, Vir_read_value_gpio3, status); 
		//	
		Check = 0;
		for(i = 0; i < 8; i++) begin
			if(data_random_gpio1[i:i] == PinIsOutput) begin
				if(RTL_read_value_gpio1[i:i] != data_random_gpio1[i:i]) begin
				Check = Error; break;
				end 
			end 
			if(data_random_gpio2[i:i] == PinIsOutput) begin
				if(RTL_read_value_gpio2[i:i] != data_random_gpio2[i:i]) begin
				Check = Error; break;
				end 
			end 
			if(data_random_gpio3[i:i] == PinIsOutput) begin
				if(RTL_read_value_gpio3[i:i] != data_random_gpio3[i:i]) begin
				Check = Error; break;
				end 
			end 			
			end 
		if(Check == NoError) begin
			`uvm_info( get_type_name(), $sformatf( "\n\n ***ok, line 338 ***\n\n"), UVM_LOW);
			end
		else begin
			`uvm_error(get_type_name(), "** Fail, line 341 **");
			end 
		end 


    #500us; // Arbitrary time
    //----------------------------------------------------------------------------------------------
    // Test result:
    //----------------------------------------------------------------------------------------------
    errorCount += report_server.get_severity_count( UVM_ERROR );

    if (errorCount == 0) begin
      `uvm_info( get_type_name(), "TokenUp_SysTS_394_vseq: All checks PASS", UVM_LOW );
    end
    else begin
      `uvm_info(get_type_name(), $psprintf ("TokenUp_SysTS_394_vseq: FAILED with %0d errors.", errorCount), UVM_LOW);
    end

    // End of sequence message
    info_end_vseq ( "TokenUp_SysTS_394_vseq" );

  endtask : body
endclass
