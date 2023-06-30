import React, { useState } from 'react';
import Chart from 'react-google-charts';

const GaugeChartComponent = ({ title, data: initialData }) => {
    const [data, setData] = useState(0);

    const updateData = (value) => {
        if (value > 0) {
            setData(value);
        }
    };

    const chartData = [
        ['Label', 'Value'],
        [title, data],
    ];

    const options = {
        width: '100%',
        height: 300,
        redFrom: 90,
        redTo: 100,
        yellowFrom: 75,
        yellowTo: 90,
        minorTicks: 5,
    };

    // Update the data value when the initialData changes
    React.useEffect(() => {
        updateData(initialData);
    }, [initialData]);

    return (
        <Chart
            chartType="Gauge"
            data={chartData}
            options={options}
            rootProps={{ 'data-testid': '1' }}
        />
    );
};

export default GaugeChartComponent;
