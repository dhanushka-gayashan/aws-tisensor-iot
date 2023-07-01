import React from 'react';
import { ThemeProvider } from '@mui/material/styles';
import theme from './theme';
import MainContainer from "./components/MainContainer";
import SubscriptionComponent from "./components/SubscriptionComponent";
import DataVisualizationComponent from "./components/DataVisualizationComponent";
import Footer from "./components/Footer";

const App = () => {
    return (
        <ThemeProvider theme={theme}>
            <MainContainer>
                <SubscriptionComponent />
                <div style={{ marginTop: '30px' }} /> {/* Add margin-top for spacing */}
                <DataVisualizationComponent />
            </MainContainer>
            <Footer />
        </ThemeProvider>
    );
};

export default App;
