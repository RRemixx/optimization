/////////////////////////////////////////////////////////////////////////
//                                                                     //
//   Modulename :  id_stage.v                                          //
//                                                                     //
//  Description :  instruction decode (ID) stage of the pipeline;      // 
//                 decode the instruction fetch register operands, and // 
//                 compute immediate operand (if applicable)           // 
//                                                                     //
/////////////////////////////////////////////////////////////////////////


`timescale 1ns/100ps


  // Decode an instruction: given instruction bits IR produce the
  // appropriate datapath control signals.
  //
  // This is a *combinational* module (basically a PLA).
  //
module decoder(

	//input [31:0] inst,
	//input valid_inst_in,  // ignore inst when low, outputs will
	                      // reflect noop (except valid_inst)
	//see sys_defs.svh for definition
	input IF_ID_PACKET if_packet,
	
	output ALU_OPA_SELECT opa_select,
	output ALU_OPB_SELECT opb_select,
	output DEST_REG_SEL   dest_reg, // mux selects
	output ALU_FUNC       alu_func,
	output logic rd_mem, wr_mem, cond_branch, uncond_branch,
	output logic csr_op,    // used for CSR operations, we only used this as 
	                        //a cheap way to get the return code out
	output logic halt,      // non-zero on a halt
	output logic illegal,    // non-zero on an illegal instruction
	output logic valid_inst  // for counting valid instructions executed
	                        // and for making the fetch stage die on halts/
	                        // keeping track of when to allow the next
	                        // instruction out of fetch
	                        // 0 for HALT and illegal instructions (die on halt)

);

	INST inst;
	logic valid_inst_in;
	
	assign inst          = if_packet.inst;
	assign valid_inst_in = if_packet.valid;
	assign valid_inst    = valid_inst_in & ~illegal;
	
	always_comb begin
		// default control values:
		// - valid instructions must override these defaults as necessary.
		//	 opa_select, opb_select, and alu_func should be set explicitly.
		// - invalid instructions should clear valid_inst.
		// - These defaults are equivalent to a noop
		// * see sys_defs.vh for the constants used here
		opa_select = OPA_IS_RS1;
		opb_select = OPB_IS_RS2;
		alu_func = ALU_ADD;
		dest_reg = DEST_NONE;
		csr_op = `FALSE;
		rd_mem = `FALSE;
		wr_mem = `FALSE;
		cond_branch = `FALSE;
		uncond_branch = `FALSE;
		halt = `FALSE;
		illegal = `FALSE;
		if(valid_inst_in) begin
			casez (inst) 
				`RV32_LUI: begin
					dest_reg   = DEST_RD;
					opa_select = OPA_IS_ZERO;
					opb_select = OPB_IS_U_IMM;
				end
				`RV32_AUIPC: begin
					dest_reg   = DEST_RD;
					opa_select = OPA_IS_PC;
					opb_select = OPB_IS_U_IMM;
				end
				`RV32_JAL: begin
					dest_reg      = DEST_RD;
					opa_select    = OPA_IS_PC;
					opb_select    = OPB_IS_J_IMM;
					uncond_branch = `TRUE;
				end
				`RV32_JALR: begin
					dest_reg      = DEST_RD;
					opa_select    = OPA_IS_RS1;
					opb_select    = OPB_IS_I_IMM;
					uncond_branch = `TRUE;
				end
				`RV32_BEQ, `RV32_BNE, `RV32_BLT, `RV32_BGE,
				`RV32_BLTU, `RV32_BGEU: begin
					opa_select  = OPA_IS_PC;
					opb_select  = OPB_IS_B_IMM;
					cond_branch = `TRUE;
				end
				`RV32_LB, `RV32_LH, `RV32_LW,
				`RV32_LBU, `RV32_LHU: begin
					dest_reg   = DEST_RD;
					opb_select = OPB_IS_I_IMM;
					rd_mem     = `TRUE;
				end
				`RV32_SB, `RV32_SH, `RV32_SW: begin
					opb_select = OPB_IS_S_IMM;
					wr_mem     = `TRUE;
				end
				`RV32_ADDI: begin
					dest_reg   = DEST_RD;
					opb_select = OPB_IS_I_IMM;
				end
				`RV32_SLTI: begin
					dest_reg   = DEST_RD;
					opb_select = OPB_IS_I_IMM;
					alu_func   = ALU_SLT;
				end
				`RV32_SLTIU: begin
					dest_reg   = DEST_RD;
					opb_select = OPB_IS_I_IMM;
					alu_func   = ALU_SLTU;
				end
				`RV32_ANDI: begin
					dest_reg   = DEST_RD;
					opb_select = OPB_IS_I_IMM;
					alu_func   = ALU_AND;
				end
				`RV32_ORI: begin
					dest_reg   = DEST_RD;
					opb_select = OPB_IS_I_IMM;
					alu_func   = ALU_OR;
				end
				`RV32_XORI: begin
					dest_reg   = DEST_RD;
					opb_select = OPB_IS_I_IMM;
					alu_func   = ALU_XOR;
				end
				`RV32_SLLI: begin
					dest_reg   = DEST_RD;
					opb_select = OPB_IS_I_IMM;
					alu_func   = ALU_SLL;
				end
				`RV32_SRLI: begin
					dest_reg   = DEST_RD;
					opb_select = OPB_IS_I_IMM;
					alu_func   = ALU_SRL;
				end
				`RV32_SRAI: begin
					dest_reg   = DEST_RD;
					opb_select = OPB_IS_I_IMM;
					alu_func   = ALU_SRA;
				end
				`RV32_ADD: begin
					dest_reg   = DEST_RD;
				end
				`RV32_SUB: begin
					dest_reg   = DEST_RD;
					alu_func   = ALU_SUB;
				end
				`RV32_SLT: begin
					dest_reg   = DEST_RD;
					alu_func   = ALU_SLT;
				end
				`RV32_SLTU: begin
					dest_reg   = DEST_RD;
					alu_func   = ALU_SLTU;
				end
				`RV32_AND: begin
					dest_reg   = DEST_RD;
					alu_func   = ALU_AND;
				end
				`RV32_OR: begin
					dest_reg   = DEST_RD;
					alu_func   = ALU_OR;
				end
				`RV32_XOR: begin
					dest_reg   = DEST_RD;
					alu_func   = ALU_XOR;
				end
				`RV32_SLL: begin
					dest_reg   = DEST_RD;
					alu_func   = ALU_SLL;
				end
				`RV32_SRL: begin
					dest_reg   = DEST_RD;
					alu_func   = ALU_SRL;
				end
				`RV32_SRA: begin
					dest_reg   = DEST_RD;
					alu_func   = ALU_SRA;
				end
				`RV32_MUL: begin
					dest_reg   = DEST_RD;
					alu_func   = ALU_MUL;
				end
				`RV32_MULH: begin
					dest_reg   = DEST_RD;
					alu_func   = ALU_MULH;
				end
				`RV32_MULHSU: begin
					dest_reg   = DEST_RD;
					alu_func   = ALU_MULHSU;
				end
				`RV32_MULHU: begin
					dest_reg   = DEST_RD;
					alu_func   = ALU_MULHU;
				end
				`RV32_CSRRW, `RV32_CSRRS, `RV32_CSRRC: begin
					csr_op = `TRUE;
				end
				`WFI: begin
					halt = `TRUE;
				end
				default: illegal = `TRUE;

		endcase // casez (inst)
		end // if(valid_inst_in)
	end // always
endmodule // decoder


module hazard_comparator_ra(
	input DETECTOR_PACKET ex_dp,
	input DETECTOR_PACKET me_dp,
	input DETECTOR_PACKET wb_dp,
	input [4:0] ra_idx,
	input inst_sw,    // if inst is sw

	output FWD_SELECT fwd_out
);
	
	// ra will not be used for mem stage
	always_comb begin
		if (ex_dp.dest_reg_idx != 0 && ex_dp.inst_is_load != 1 && ra_idx == ex_dp.dest_reg_idx) begin
			fwd_out = FWD_D1;
		end 
		else if (ex_dp.dest_reg_idx != 0 && ex_dp.inst_is_load == 1 && ra_idx == ex_dp.dest_reg_idx) begin
			fwd_out = FWD_D3;
		end
		else if (me_dp.dest_reg_idx != 0 && ra_idx == me_dp.dest_reg_idx) begin
			fwd_out = FWD_D2;
		end
		else begin
			fwd_out = FWD_NH;
		end
	end

endmodule

module hazard_comparator_rb(
	input DETECTOR_PACKET ex_dp,
	input DETECTOR_PACKET me_dp,
	input DETECTOR_PACKET wb_dp,
	input [4:0] ra_idx,
	input inst_sw,    // if inst is sw

	output FWD_SELECT fwd_out
);
	// depend on nearest inst
	// the value of rb might be used in mem stage (sw)
	always_comb begin
		if (inst_sw && ex_dp.dest_reg_idx != 0 && ex_dp.inst_is_load != 1 && ra_idx == ex_dp.dest_reg_idx) begin
			fwd_out = FWD_S1;
		end
		else if (inst_sw && ex_dp.dest_reg_idx != 0 && ex_dp.inst_is_load == 1 && ra_idx == ex_dp.dest_reg_idx) begin
			fwd_out = FWD_S3;
		end
		else if (ex_dp.dest_reg_idx != 0 && ex_dp.inst_is_load != 1 && ra_idx == ex_dp.dest_reg_idx) begin
			fwd_out = FWD_D1;
		end 
		else if (ex_dp.dest_reg_idx != 0 && ex_dp.inst_is_load == 1 && ra_idx == ex_dp.dest_reg_idx) begin
			fwd_out = FWD_D3;
		end
		else if (inst_sw && me_dp.dest_reg_idx != 0 && ra_idx == me_dp.dest_reg_idx) begin
			fwd_out = FWD_S2;
		end
		else if (me_dp.dest_reg_idx != 0 && ra_idx == me_dp.dest_reg_idx) begin
			fwd_out = FWD_D2;
		end
		else begin
			fwd_out = FWD_NH;
		end
	end

endmodule





module detector(
	input reset,
	input clock,
	input br_taken,
	input illegal,
	input is_load,
	input is_store,
	input load_use_stall,
	input [4:0] ra_idx,
	input [4:0] rb_idx,
	input [4:0] dest_idx,

	output FWD_SELECT ra_fwd_out,
	output FWD_SELECT rb_fwd_out
);

	DETECTOR_PACKET ex_dp;     	// id/ex 
	DETECTOR_PACKET me_dp;		// ex/me
	DETECTOR_PACKET wb_dp;		// me/wb

	always_ff @(posedge clock) begin
		if (reset || br_taken) begin
			ex_dp.dest_reg_idx <= `SD `ZERO_REG;
			ex_dp.inst_is_load <= `SD 1'b0;
			me_dp.dest_reg_idx <= `SD `ZERO_REG;
			me_dp.inst_is_load <= `SD 1'b0;
			wb_dp.dest_reg_idx <= `SD `ZERO_REG;
			wb_dp.inst_is_load <= `SD 1'b0;
		end
		else if (illegal || load_use_stall) begin
			wb_dp              <= `SD me_dp;
			me_dp              <= `SD ex_dp;
			ex_dp.dest_reg_idx <= `SD `ZERO_REG;
			ex_dp.inst_is_load <= `SD 1'b0;
		end
		else begin
			wb_dp              <= `SD me_dp;
			me_dp              <= `SD ex_dp;
			ex_dp.inst_is_load <= `SD is_load;
			ex_dp.dest_reg_idx <= `SD dest_idx;
		end
	end

	// ra
	hazard_comparator_ra hc_ra (ex_dp, me_dp, wb_dp, ra_idx, is_store, ra_fwd_out);
	// rb
	hazard_comparator_rb hc_rb (ex_dp, me_dp, wb_dp, rb_idx, is_store, rb_fwd_out);
	
endmodule

module id_stage(         
	input         clock,              // system clock
	input         reset,              // system reset
	input         br_taken,
	input         wb_reg_wr_en_out,    // Reg write enable from WB Stage
	input  [4:0] wb_reg_wr_idx_out,  // Reg write index from WB Stage
	input  [`XLEN-1:0] wb_reg_wr_data_out,  // Reg write data from WB Stage
	input  IF_ID_PACKET if_id_packet_in,
	
	output ID_EX_PACKET id_packet_out
);

    assign id_packet_out.inst = if_id_packet_in.inst;
    assign id_packet_out.NPC  = if_id_packet_in.NPC;
    assign id_packet_out.PC   = if_id_packet_in.PC;
	DEST_REG_SEL dest_reg_select; 

	// Instantiate the register file used by this pipeline
	regfile regf_0 (
		.rda_idx(if_id_packet_in.inst.r.rs1),
		.rda_out(id_packet_out.rs1_value), 

		.rdb_idx(if_id_packet_in.inst.r.rs2),
		.rdb_out(id_packet_out.rs2_value),

		.wr_clk(clock),
		.wr_en(wb_reg_wr_en_out),
		.wr_idx(wb_reg_wr_idx_out),
		.wr_data(wb_reg_wr_data_out)
	);

	// instantiate the instruction decoder
	decoder decoder_0 (
		.if_packet(if_id_packet_in),	 
		// Outputs
		.opa_select(id_packet_out.opa_select),
		.opb_select(id_packet_out.opb_select),
		.alu_func(id_packet_out.alu_func),
		.dest_reg(dest_reg_select),
		.rd_mem(id_packet_out.rd_mem),
		.wr_mem(id_packet_out.wr_mem),
		.cond_branch(id_packet_out.cond_branch),
		.uncond_branch(id_packet_out.uncond_branch),
		.csr_op(id_packet_out.csr_op),
		.halt(id_packet_out.halt),
		.illegal(id_packet_out.illegal),
		.valid_inst(id_packet_out.valid)
	);

	// mux to generate dest_reg_idx based on
	// the dest_reg_select output from decoder
	always_comb begin
		case (dest_reg_select)
			DEST_RD:    id_packet_out.dest_reg_idx = if_id_packet_in.inst.r.rd;
			DEST_NONE:  id_packet_out.dest_reg_idx = `ZERO_REG;
			default:    id_packet_out.dest_reg_idx = `ZERO_REG; 
		endcase
	end

	// hazard detector
	detector detector_0 (
		.reset(reset),
		.clock(clock),
		.br_taken(br_taken),
		.illegal(id_packet_out.illegal),
		.is_load(id_packet_out.rd_mem),
		.is_store(id_packet_out.wr_mem),
		.load_use_stall(id_packet_out.load_use_stall),
		.ra_idx(if_id_packet_in.inst.r.rs1),
		.rb_idx(if_id_packet_in.inst.r.rs2),
		.dest_idx(id_packet_out.dest_reg_idx),
		.ra_fwd_out(id_packet_out.ra_fwd_type),
		.rb_fwd_out(id_packet_out.rb_fwd_type)
	);

	assign id_packet_out.load_use_stall = (id_packet_out.ra_fwd_type == FWD_D3) | (id_packet_out.rb_fwd_type == FWD_D3)  | (id_packet_out.rb_fwd_type == FWD_S3);    // load use hazard or not
   
endmodule // module id_stage
