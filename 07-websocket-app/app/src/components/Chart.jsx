import React from 'react';
import { Chart } from 'react-google-charts';

const MyChart = () => {
    const chartData = [
        ['City', 'Population'],
        ['New York', 8622698],
        ['Los Angeles', 3999759],
        ['Chicago', 2716450],
        ['Houston', 2312717],
        ['Phoenix', 1626078],
    ];

    return (
        <Chart
            width={'500px'}
            height={'300px'}
            chartType="ColumnChart"
            data={chartData}
        />
    );
};

export default MyChart;
