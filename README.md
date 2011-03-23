# Exceptional API Wrapper

## Intro

A wrapper on the [Exceptional](http://getexceptional.com) API for iOS. This wrapper uses the
device's internet connection to report errors to your Exceptional account.

## Quickstart

In your terminal:

- git clone git@github.com:leviathan/getexceptional-api-wrapper.git

In your Xcode project:

- drag the GetexceptionalAPI folder into your project
- drag the external folder into your project (decide which dependencies you need)
- open the exceptional.plist file and add your API_KEY (this can be retrieved from the exceptional website)

## External Dependencies

- [ASIHTTPRequest](http://allseeing-i.com/ASIHTTPRequest)
- [JSON framework](https://github.com/stig/json-framework)

## Using the Wrapper in your code

### The Basics

You only need to import the API files into your project. You may need to reference the external
dependencies as well. 

### Instantiating the API object

Setup the Wrapper as a default NSSetUncaughtExceptionHandler. This way all exceptions, which occur
in the app will be automatically reported to your account.

    [[GTExceptionalAPI sharedAPI] setupExceptionHandling];

Doing this is optional. You may also report exceptions directly by using a try - catch block.

    @try {
        ... your potentially risky code
    }
    @catch (NSException *exception) {
        [[GTExceptionalAPI sharedAPI] reportException:exception wait:NO];
    }


## Todo's

- log the error in a file and send it the next time the app starts
- handle error signals and report them as well