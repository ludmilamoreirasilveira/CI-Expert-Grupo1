// Enquanto o mux4.v da RTL estiver sem logica, o resultado esperado eh FALHOU
`timescale 1ns/1ps

module tb_mux4;

    localparam WIDTH = 8; 

    reg  [WIDTH-1:0] din_1, din_2, din_3, din_4;
    reg  [1:0]       in_select;
    wire [WIDTH-1:0] dout;

    integer erros  = 0;
    integer testes = 0;

    mux4 #(.WIDTH(WIDTH)) dut (
        .din_1     (din_1),
        .din_2     (din_2),
        .din_3     (din_3),
        .din_4     (din_4),
        .in_select (in_select),
        .dout      (dout)
    );

    function [WIDTH-1:0] esperado(
        input [1:0]       sel,
        input [WIDTH-1:0] a,
        input [WIDTH-1:0] b,
        input [WIDTH-1:0] c,
        input [WIDTH-1:0] d
    );
        begin
            if (sel == 2'b00)      esperado = a;
            else if (sel == 2'b01) esperado = b;
            else if (sel == 2'b10) esperado = c;
            else                   esperado = d;
        end
    endfunction

    task checa;
        reg [WIDTH-1:0] exp;
        begin
            #1;
            exp    = esperado(in_select, din_1, din_2, din_3, din_4);
            testes = testes + 1;
            if (dout !== exp) begin
                erros = erros + 1;
                $display("ERRO: sel=%b | esperado=%h | obtido=%h", in_select, exp, dout);
            end
        end
    endtask

    //4 valores teset
    reg [WIDTH-1:0] valores_teste [0:3];
    integer s, i;

    initial begin
        //testar integridade eletrica/curtos nos barramentos
        valores_teste[0] = 8'h00; 
        valores_teste[1] = 8'hFF; 
        valores_teste[2] = 8'hAA; 
        valores_teste[3] = 8'h55;

        din_1 = 0; din_2 = 0; din_3 = 0; din_4 = 0; in_select = 0;

        for (s = 0; s < 4; s = s + 1) begin
            for (i = 0; i < 4; i = i + 1) begin
                in_select = s;
                
                din_1 = ~valores_teste[i];
                din_2 = ~valores_teste[i];
                din_3 = ~valores_teste[i];
                din_4 = ~valores_teste[i];

                if (s == 0)      din_1 = valores_teste[i];
                else if (s == 1) din_2 = valores_teste[i];
                else if (s == 2) din_3 = valores_teste[i];
                else if (s == 3) din_4 = valores_teste[i];

                checa;
            end
        end

        $display("FIM: %0d testes, %0d erros", testes, erros);
        if (erros == 0 && testes > 0) $display("RESULTADO: PASSOU");
        else                          $display("RESULTADO: FALHOU");
        $finish;
    end

    initial begin
        $dumpfile("wave_mux4.vcd");
        $dumpvars(0, tb_mux4);
    end

endmodule