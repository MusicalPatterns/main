#!/usr/bin/env bash

grep -r -L "// tslint:disable no-reaching-imports" --include="*indexForTest.ts" .
grep -r -L "// tslint:disable no-magic-numbers" --include="*constants.ts" .
