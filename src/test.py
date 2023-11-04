import cocotb
from cocotb.clock import Clock
from cocotb.triggers import RisingEdge, FallingEdge, Timer, ClockCycles

@cocotb.test()
async def test_my_design(dut):
    dut._log.info("start")

    clock = Clock(dut.clk, 1, units="ns")
    cocotb.start_soon(clock.start())

    dut.rst_n.value = 0 # low to reset
    await ClockCycles(dut.clk, 10)
    dut.rst_n.value = 1 # take out of reset

    dut.ui_in.value = 0
    await ClockCycles(dut.clk, 2000)

    dut.ui_in.value = 20
    await ClockCycles(dut.clk, 5000)
    dut._log.info("ending")