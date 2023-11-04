`default_nettype none

module hh  (
    input  wire [15:0] current, // 000001010_00000 --> 10
    output wire [15:0] V_new,
    input  wire        clk,
    input  wire        rst_n
     );

    //reg [7:0] next_state, threshold, current, INa, IK, IKleak, m_alph, m_beta, m_act, h_alph, h_beta, h_act, n_alph, n_beta, n_act;
    reg [15:0]  Cm, gNa, gK, gL, ENa, EK, EL;
    reg [15:0]  alpha_n, beta_n, alpha_m, beta_m, alpha_h, beta_h;
    reg [15:0]  n, m, h;
    reg [15:0]  V, dt; // 000000000.00001 --> 0.03..
    wire [15:0]  alpha_n_new, alpha_m_new, alpha_h_new;
    wire [15:0]  beta_n_new, beta_m_new, beta_h_new;
    wire [15:0] gNat, gKt, gLt;
    wire [15:0] INa, IK, IL;
    wire [15:0] one_bit;
    wire [15:0] n_new, m_new, h_new;


    always @(posedge clk) begin
        if (!rst_n) begin //at least two cycles
            Cm      <= 16'b000000001_0000000; // 1.0
            gNa     <= 16'b001111000_0000000; // 120.0
            gK      <= 16'b000100100_0000000; // 36.0
            gL      <= 16'b000000000_0100110; // 0.3 --> 0.25
            ENa     <= 16'b000110010_0000000; // 50
            EK      <= 16'b110110011_0000000; // -77  
            EL      <= 16'b111001001_1001111;  // -54.387: 000110110 --> 111001001
            V       <= 16'b110111111_0000000; // -65
            alpha_n <= 16'b000000000_1000110; // 0.55 -> 0.5
            beta_n  <= 16'b000000000_0000111; // 0.055 --> 0.0125
            alpha_m <= 16'b000000100_0001000; // 4.07 --> 4
            beta_m  <= 16'b000000000_0001101; // 0.108 --> 0.125
            alpha_h <= 16'b000000000_0000001; // 0.00271 --> 0.125 ///// clipped
            beta_h  <= 16'b000000000_1111100; // 0.97 --> 0.875
            dt      <= beta_n;
            // alpha_n_new <= 16'b000000000_10001; // 0.55 -> 0.5
            // beta_n_new <= 16'b000000000_00001; // 0.055 --> 0.0125
            // alpha_m_new <= 16'b000000100_00010; // 4.07 --> 4
            // beta_m_new <= 16'b000000000_00011; // 0.108 --> 0.125
            // alpha_h_new <= 16'b000000000_00001; // 0.00271 --> 0.125
            // beta_h_new <= 16'b000000000_11111; // 0.97 --> 0.875

            // Initial values for m,n and h
            n <= 16'b00000000000_11101;
            m <= 16'b00000000000_11111;
            h <= 16'b00000000000_00001; // could be 0

        end else begin
            V <= V_new;
            n <= n_new;
            m <= m_new; 
            h <= h_new;

        end


    end

    assign one_bit = Cm;

    assign gNat = gNa * h * (m*m*m);
    assign gKt  = gK * (n*n*n*n);
    assign gLt  = gL;

    assign INa = gNat * (V - ENa);
    assign IK  = gKt * (V - EK);
    assign IL  = gLt * (V - EL);

    assign V_new = V + (current - INa - IK - IL) / Cm * dt;

    assign n_new = n + ((alpha_n * (one_bit - n)) - beta_n * n) * dt;
    assign m_new = m + ((alpha_m * (one_bit - m)) - beta_m * m) * dt;
    assign h_new = h + ((alpha_h * (one_bit - h)) - beta_h * h) * dt;

    // assign n_new = n + ((alpha_n_new * (one_bit - n)) - beta_n_new * n) * dt;
    // assign m_new = m + ((alpha_m_new * (one_bit - m)) - beta_m_new * m) * dt;
    // assign h_new = h + ((alpha_h_new * (one_bit - h)) - beta_h_new * h) * dt;
    

    hh_state hh_state(.voltage(V), .alpha_n(alpha_n_new), .alpha_m(alpha_m_new), 
    .alpha_h(alpha_h_new), .beta_n(beta_n_new), .beta_m(beta_m_new), 
    .beta_h(beta_h_new), .clk(clk), .rst_n(rst_n));

endmodule
