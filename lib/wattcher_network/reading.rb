class WattcherNetwork
  class Reading
    module Sensors
      CURRENT = 4
      VOLTAGE = 0
    end

    MAINSVPP = 170 * 2  # +-170V is what 120Vrms ends up being (= 120*2sqrt(2))
    CURRENT_NORM = 15.5 # Conversion to amps from ADC

    VrefCalibration = [
      nil,  # Calibration for sensor #0
      497,  # Calibration for sensor #1
      nil   # etc... approx ((2.4v * (10Ko/14.7Ko)) / 3
    ]

    attr_reader :amperage_data, :voltage_data, :wattage_data

    def initialize(packet)
      @voltage_data = _parse_voltage_data(packet)
      @amperage_data = _parse_amperage_data(packet)
      @wattage_data = _calculate_wattage_data(@voltage_data, @amperage_data)
    end

    def to_s
      str = ""
      str += @voltage_data.inspect + "\n"
      str += @amperage_data.inspect + "\n"

      @voltage_data.size.times do |i|
        volts = "%7.2f" % @voltage_data[i]
        amps = "%6.2f" % @amperage_data[i]
        watts = "%7.2f" % @wattage_data[i]
        str += "#{volts} * #{amps} = #{watts}\n"
      end
      str
    end

    def _parse_amperage_data(packet)
      data = packet.analog_samples.map { |sensor_readings| sensor_readings[Sensors::CURRENT] }

      offset = VrefCalibration[packet.address]
      data.map do |amp|
        a = amp - offset
        a / CURRENT_NORM
      end
    end

    def _parse_voltage_data(packet)
      data = packet.analog_samples.map { |sensor_readings| sensor_readings[Sensors::VOLTAGE] }

      avg = data.inject(0.0) { |result, volt| result + volt } / data.size
      vpp = data.max - data.min

      data.map do |voltage|
        # Remove DC bias
        v = voltage - avg
        (v * MAINSVPP) / vpp
      end
    end

    def _calculate_wattage_data(voltage_data, amperage_data)
      voltage_data.zip(amperage_data).map { |v, a| v * a }
    end
  end
end
