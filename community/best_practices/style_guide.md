<!--
  Copyright 2018-2021 Cargill Incorporated
  Licensed under Creative Commons Attribution 4.0 International License
  https://creativecommons.org/licenses/by/4.0/
-->

# UI Style Guide

The [Grid UI](https://github.com/hyperledger/grid/tree/master/ui) is an
application build using the Canopy framework. This allows us to build Grid UI
components as plugins which fit into the larger Grid UI environment. This
document provides a styling reference for developers and designers creating UI
components for Grid.

## Logos

### Full Logo

![]({% link community/images/GridLogo.svg %} "Grid Logo")

### Square Logo

![]({% link community/images/GridLogoSmall.svg %} "Square Logo")

## Colors

![]({% link community/images/Colors.svg %} "Colors")

## Typography

![]({% link community/images/Typography.svg %} "Typography")


## Components

### Text Field

![]({% link community/images/TextField.svg %} "TextField")

1. Label
2. Container
3. Icon
4. Input Text
5. Error Text

#### Label

The label text gives the user information on what input text is expected. If the
user tries to submit a form without filling out a required field, a brand-color
asterisk will appear by the label to indicate the missing input.

```css
font-family: Arial;
font-style: normal;
font-weight: bold;
font-size: 14px;
line-height: 19px;
display: flex;
align-items: center;
color: #595C60;
```

#### Container

The container surrounds the input text and icon of the field. Containers use the
Border - Light color, but turn to the Brand - Primary color when selected. They
have an outer margin of 4px and an inner padding of 14px.

```css
background: #FFFFFF;
border: 2px solid #F35F19;
box-sizing: border-box;
border-radius: 5px;
```

#### Icon

An icon is a flexible and optional element of a text field. It can be used for
things such as dropdown icons, clear buttons, calendar buttons for a
date-picker, a hide button for a password field, etc. Icons that function as
buttons should have the placeholder text color, or the body text color when
hovered or selected. Other icons can be styled as appropriate, but they should
always be on the far right or far left side of the container.

```css
width: 24px;
height: 24px;
```

#### Input Text

Input text is the place in the text field where the user can type in some text,
or where a user's selection is displayed for a dropdown or date-picker field.
Input text uses the Body text style.

Text fields can optionally have placeholder input text. This text should use the
Placeholder text style. It should not be selectable and it should be visible
only when the input text field is empty.

```css
font-family: Helvetica;
font-style: normal;
font-weight: normal;
font-size: 14px;
line-height: 125%;
display: flex;
align-items: center;
```
#### Error Help Text

If form submission fails due to an invalid value in a text field, this text can
appear to help the user by indicating the error cause or listing the valid
values. This text should be kept to one line and use the Error text style. Note
that the error help text is included in the dimensions of the text field
component, so it should not impact the positioning of text fields below it on a
form.

```css
font-family: Helvetica;
font-style: normal;
font-weight: normal;
font-size: 11px;
line-height: 18px;
display: flex;
align-items: center;
color: #F32019;
```
