import React from 'react';
import { ThemeProvider } from '@mui/material/styles';
import theme from './theme';
import MainContainer from "./components/MainContainer";
import SubscriptionComponent from "./components/SubscriptionComponent";
import DataVisualizationComponent from "./components/DataVisualizationComponent";

const App = () => {
    return (
        <ThemeProvider theme={theme}>
            <MainContainer>
                <SubscriptionComponent />
                <div style={{ marginTop: '30px' }} /> {/* Add margin-top for spacing */}
                <DataVisualizationComponent />
            </MainContainer>
        </ThemeProvider>
    );
};

export default App;
