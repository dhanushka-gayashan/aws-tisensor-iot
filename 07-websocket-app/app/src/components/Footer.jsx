import React from 'react';
import { Box, Typography, useTheme } from '@mui/material';

const Footer = () => {
    const year = new Date().getFullYear();
    const theme = useTheme();  // Use the theme defined in App.js

    return (
        <Box sx={{
            position: 'fixed',
            left: 0,
            bottom: 0,
            width: '100%',
            backgroundColor: theme.palette.footer.main,  // use the color
            color: 'white',
            textAlign: 'center',
            padding: 2,
        }}>
            <Typography variant="body1">Copyright © {year} Dhanushka Kohombange. All Rights Reserved.</Typography>
        </Box>
    );
};

export default Footer;
