import React, { useState } from 'react';
import { Container, Typography, TextField, Button, Box, Snackbar } from '@mui/material';
import { styled } from '@mui/system';
import { v4 as uuidv4 } from 'uuid';

const StyledContainer = styled(Container)(({ theme }) => ({
    width: '95%',
    height: '100px',
    border: '1px solid #eee',
    boxShadow: '0px 2px 6px rgba(0, 0, 0, 0.1)',
    display: 'flex',
    alignItems: 'center',
    justifyContent: 'space-between',
    padding: theme.spacing(2),
    margin: 'auto',
}));

const SubscriptionComponent = () => {
    const [phoneNumber, setPhoneNumber] = useState('');
    const [uuid, setUuid] = useState('');
    const [alert, setAlert] = useState('');

    const handleSubscribe = () => {
        if (phoneNumber.startsWith('+64') && /^[0-9+]+$/.test(phoneNumber)) {
            const generatedUuid = uuidv4().toString();
            setPhoneNumber('');
            setUuid(generatedUuid);

            const payload = {
                mobile: phoneNumber,
                uuid: generatedUuid,
            };

            fetch('https://api.iot.dhanuzone.com/mobile', {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/json',
                },
                body: JSON.stringify(payload),
            })
                .then((response) => {
                    if (response.ok) {
                        setAlert('Success: Subscription added!');
                    } else {
                        setAlert('Error: Subscription failed!');
                    }
                })
                .catch((error) => {
                    setAlert('Error: Subscription failed!');
                });
        } else {
            setAlert('Error: Invalid phone number!');
        }
    };

    const handleUnsubscribe = () => {
        if (phoneNumber.startsWith('+64') && /^[0-9+]+$/.test(phoneNumber)) {
            const formattedPhoneNumber = phoneNumber.replace('+', '%2B');

            fetch(`https://api.iot.dhanuzone.com/mobile?number=${formattedPhoneNumber}`, {
                method: 'DELETE',
            })
                .then((response) => {
                    if (response.ok) {
                        setAlert('Success: Unsubscription successful!');
                    } else {
                        setAlert('Error: Unsubscription failed!');
                    }
                })
                .catch((error) => {
                    setAlert('Error: Unsubscription failed!');
                });
        } else {
            setAlert('Error: Invalid phone number!');
        }
    };

    const handleAlertClose = () => {
        setAlert('');
    };

    const handleInputChange = (e) => {
        const inputValue = e.target.value;
        const cleanedInputValue = inputValue.replace(/[^0-9+]/g, '');
        setPhoneNumber(cleanedInputValue);
    };

    return (
        <StyledContainer>
            <Box display="flex" alignItems="center">
                <Typography variant="body1" fontWeight="bold" color="#7e57c2" marginRight="8px">
                    Phone Number (with +64)
                </Typography>
                <TextField
                    variant="outlined"
                    value={phoneNumber}
                    onChange={handleInputChange}
                    sx={{
                        '& label.Mui-focused': { color: '#7e57c2' },
                        width: '70%',
                        height: '40px',
                    }}
                    inputProps={{ style: { fontSize: '14px' }, pattern: '[0-9+]*' }}
                />
            </Box>
            <Box display="flex" alignItems="center" justifyContent="center" gap={1}>
                <Button
                    variant="contained"
                    color="success"
                    onClick={handleSubscribe}
                    sx={{ backgroundColor: '#66bb6a', width: '100%', height: '50px' }}
                >
                    Subscribe
                </Button>
                <Button
                    variant="contained"
                    color="error"
                    onClick={handleUnsubscribe}
                    sx={{ backgroundColor: '#ef5350', width: '100%', height: '50px' }}
                >
                    Unsubscribe
                </Button>
            </Box>
            <Snackbar
                open={!!alert}
                autoHideDuration={5000}
                onClose={handleAlertClose}
                anchorOrigin={{ vertical: 'top', horizontal: 'center' }}
            >
                <Box
                    sx={{
                        backgroundColor: alert.includes('Error') ? 'rgba(255, 0, 0, 0.8)' : 'rgba(76, 175, 80, 0.8)',
                        color: '#ffffff',
                        padding: '8px',
                        borderRadius: '4px',
                    }}
                >
                    <Typography variant="body1">{alert}</Typography>
                </Box>
            </Snackbar>
        </StyledContainer>
    );
};

export default SubscriptionComponent;
