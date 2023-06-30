import React from 'react';
import { Chart } from 'react-google-charts';

const GaugeChartComponent = ({ title, data, max, redFrom, redTo, yellowFrom, yellowTo, greenFrom, greenTo }) => {
    const chartData = [
        ['Label', 'Value'],
        [title, data],
    ];

    const options = {
        width: '100%',
        height: 300,
        max: max,
        redFrom: redFrom,
        redTo: redTo,
        yellowFrom: yellowFrom,
        yellowTo: yellowTo,
        greenFrom: greenFrom,
        greenTo: greenTo,
        minorTicks: 5,
    };

    return (
        <Chart
            chartType="Gauge"
            loader={<div>Loading Chart</div>}
            data={chartData}
            options={options}
            width={options.width}
            height={options.height}
        />
    );
};

export default GaugeChartComponent;
