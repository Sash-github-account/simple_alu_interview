// ALU Package File

`ifnef __ALU_PKG_SVH__
  `define __ALU_PKG_SVH__

package alu_pkg;

  localparam INT_WIDTH = 8;

  localparam NUM_WORD_WIDTH = 10;

  typedef enum logic [2:0] {
    ADD,
    SUB,
    MUL,
    DIV,
    MEAN,
  } ALU_OP_E;

  typedef logic [INT_WIDTH - 1:0] uint_t;
  
  typedef struct packed {
    logic        vld;
    uint_t       data;
  } uint_vld_t;

  typedef struct packed {
    logic        vld;
    ALU_OP_E     opcode;
    logic [NUM_WORTH_WIDTH-1:0] num_words;
  } alu_cmd_t;

endpackage : alu_pkg

`endif // guard
