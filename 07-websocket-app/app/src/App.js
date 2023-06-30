import React from 'react';
import { ThemeProvider } from '@mui/material/styles';
import theme from './theme';
import MainContainer from "./components/MainContainer";
import SubscriptionComponent from "./components/SubscriptionComponent";

const App = () => {
    return (
        <ThemeProvider theme={theme}>
            <MainContainer>
                <SubscriptionComponent />
                {/*<AnotherComponent />*/}
                {/* Add more components here */}
            </MainContainer>
        </ThemeProvider>
    );
};

export default App;
