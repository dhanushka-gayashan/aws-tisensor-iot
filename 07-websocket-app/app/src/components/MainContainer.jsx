import React from 'react';
import { Container, Typography } from '@mui/material';
import { Box } from '@mui/system';
import Footer from "./Footer";

const MainContainer = ({ children }) => {
    return (
        <Container
            sx={{
                display: 'flex',
                justifyContent: 'center',
                alignItems: 'center',
                height: '90vh',
                width: '90%',
                margin: '40px auto 0',
                boxShadow: '0px 0px 10px rgba(0, 0, 0, 0.2)',
            }}
        >
            <Box
                sx={{
                    p: 4,
                    borderRadius: '12px',
                    border: '2px solid #9c27b0',
                    backgroundColor: '#fafafa',
                    width: '100%',
                    boxShadow: '0px 0px 5px rgba(0, 0, 0, 0.1)',
                }}
            >
                <Typography
                    variant="h3"
                    component="h1"
                    align="center"
                    mb={4}
                    sx={{
                        color: '#7e57c2',
                        fontFamily: 'Poppins, sans-serif',
                    }}
                >
                    Stay&#x2191;2Date
                </Typography>
                {children}
            </Box>
        </Container>
    );
};

export default MainContainer;
