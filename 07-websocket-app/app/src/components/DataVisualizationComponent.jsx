import React, { useEffect, useState } from 'react';
import { Container, Button, Box } from '@mui/material';
import { styled } from '@mui/system';
import GaugeChartComponent from './GaugeChartComponent';

const StyledContainer = styled(Container)(({ theme }) => ({
    width: '95%',
    height: '100%',
    border: '1px solid #eee',
    boxShadow: '0px 2px 6px rgba(0, 0, 0, 0.1)',
    display: 'flex',
    alignItems: 'center',
    justifyContent: 'center',
    flexDirection: 'column',
    padding: theme.spacing(2),
    margin: 'auto',
}));

const DataVisualizationComponent = () => {
    const [message, setMessage] = useState(null);
    const [socket, setSocket] = useState(null);

    useEffect(() => {
        establishWebSocketConnection();

        return () => {
            closeWebSocketConnection();
        };
    }, []);

    const establishWebSocketConnection = () => {
        const newSocket = new WebSocket('wss://ws.iot.dhanuzone.com/');

        newSocket.onopen = () => {
            console.log('WebSocket connection established.');
        };

        newSocket.onmessage = (event) => {
            const data = JSON.parse(event.data);
            if (data.action === 'BROADCAST' && data.response && data.response.message) {
                setMessage(data.response.message);
            }
        };

        newSocket.onclose = () => {
            console.log('WebSocket connection closed.');
        };

        setSocket(newSocket);
    };

    const closeWebSocketConnection = () => {
        if (socket && socket.readyState === WebSocket.OPEN) {
            socket.close();
        }
    };

    const handleRefreshConnection = () => {
        closeWebSocketConnection();
        establishWebSocketConnection();
    };

    return (
        <StyledContainer>
            <Box display="flex" alignItems="center" justifyContent="center" gap={2}>
                <GaugeChartComponent
                    title="Humidity"
                    data={Number(message?.humidity) || 0}
                    redFrom={50}
                    redTo={100}
                    yellowFrom={0}
                    yellowTo={30}
                    greenFrom={30}
                    greenTo={50}
                    max={100}
                />
                <GaugeChartComponent
                    title="Pressure"
                    data={Number(message?.pressure) || 0}
                    redFrom={50}
                    redTo={100}
                    yellowFrom={0}
                    yellowTo={25}
                    greenFrom={25}
                    greenTo={50}
                    max={100}
                />
                <GaugeChartComponent
                    title="Temperature"
                    data={Number(message?.temperature) || 0}
                    redFrom={35}
                    redTo={50}
                    yellowFrom={25}
                    yellowTo={35}
                    greenFrom={0}
                    greenTo={25}
                    max={50}
                />
            </Box>
            <Box mt={2}>
                <Button variant="contained" onClick={handleRefreshConnection}>
                    Refresh Connection
                </Button>
            </Box>
        </StyledContainer>
    );
};

export default DataVisualizationComponent;

