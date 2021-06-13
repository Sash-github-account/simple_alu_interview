// Stub for a INT8 divider

module div
  (
   input  alu_pkg::uint_t a,
   input  alu_pkg::uint_t b,
  
   output alu_pkg::uint_t out,
   output alu_pkg::uint_t remainder,
   );

  assign out = a / b;
  assign remainder = a % b;
  
endmodule
