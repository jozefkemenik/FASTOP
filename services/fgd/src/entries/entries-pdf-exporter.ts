import { Response } from "express"

import PdfPrinter from "pdfmake"

import * as VfsFonts from "pdfmake/build/vfs_fonts"


import { EFgdAppId, EQuestionType } from "../shared"
import {
    EResponseType, IPdfChoice, IPdfCompliance, IPdfLinkedEntry, IPdfNumericalTarget,
    IPdfQuestionStack, IPdfQuestionnaireMetaStack, IQuestionnaireEntries
} from '.'


export class EntriesPdfExporter {

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Instance Members ///////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    private _questionStack: IPdfQuestionStack[];
    private _questionnaireMetaStack: IPdfQuestionnaireMetaStack[];
    private _radioSelected =    'data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAABAAAAAQCAYAAAAf8/' +
                                '9hAAAAiUlEQVQ4ja1TwQ3AIAi8ETqCI3QER3FTRnAUR2g/0CCCMdpLSIwexykIj' +
                                'CgACMBjgvgsRAJQnUQblblDcnOqZQ7rqlkRXXlmsxgnw+b0jhFfrJEiXcYy8Z6gy/' +
                                'GqR13wXHyLrAhRBwTZE7gXBNJMYPsKx4+o1bSLCC7/aJCAH0ZZRLY/k7W5/J1fiPWEEbUBBhcAAAAASUVORK5CYII=';
    private _radioUnSelected =  'data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAABAAAAAQCAYAAAAf8/' +
                                '9hAAAAf0lEQVQ4ja2T0Q3AIAgFb5SO0BEchU0dwVEcof3RxiIarCUhMco7ngahDw' +
                                'EicKmM5WwYB5AMoc5UajtxNrqFktpV1pC288ymKCfd5vSOo/pqLTrENV6ale6Wi2' +
                                'cRFgDBApy7AFkASAvYfsSW5nFh1m8NEvwwyhXy+TNpm+7vfANGkmXRXjDeHQAAAABJRU5ErkJggg==';
    private _checkboxChecked =  'data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAABAAAAAQCAYAAAAf8/' +
                                '9hAAAA0klEQVQ4ja3TsUoDQRSF4Q83RWJjGTCFSMCUsQz4LD5B1MKX2hCIpA82Ym' +
                                'sT0gQkVQrBYCdaWmSUYTOb3YAHbnPumX8uwx3+SRnukGOcqEEV4BZfmNQE9IqAPB' +
                                'yuoyt84jo2f2+qUh8fmKJxKOACb5ihWWzGgBaOC/1zrPGc6O0ARniMgqd4xQtOgn' +
                                'cfKgno4x1POMMCS7RL8knjEht8Y4XOnonTRoDM0bWrWgA4SnjJ/Ej9RYIH2+X7U9' +
                                'UqxzWxfZthDMhwo/wzxZWHbHbAxOX6AXgNQm1UzcrhAAAAAElFTkSuQmCC';
    private _checkboxUnChecked =    'data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAABAAAAAQCAYAAAAf8/' +
                                    '9hAAAA3klEQVQ4ja2TQWrAIBBFPxFBUdAQcCEILgQXQyIhB+hRcxSPNl20WbhpY6' +
                                    'nwlu/BDA7wH++6LneeZz/Pkyfo13U5AEBrrR/HwbO01joAgIj4m3vf94/fIKL7cQ' +
                                    'AAtVautTIRtTcjE1F7HABAKYVLKTyzt8HJOXPOeSowOCklTilNBQYnxsgxxqnA4I' +
                                    'QQOIQwFRicbdt427apwOA459g5NxUYHGstW2vZe//qH3jv2+MAALTWrLVmpdRtjP' +
                                    'kxYoxpSqn7cQAAUsoupeQ/8HUL67o6IURfloXfIoTo67q6T7UQjtPPI3OMAAAAAElFTkSuQmCC';
    private _today = new Date();

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Public Methods /////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    public async execute(questionnaireEntries: IQuestionnaireEntries, warningMsg: string, res: Response): Promise<Response> {
        const fonts = {
            Roboto: {
                normal: Buffer.from(VfsFonts.pdfMake.vfs['Roboto-Regular.ttf'], 'base64'),
                bold: Buffer.from(VfsFonts.pdfMake.vfs['Roboto-Medium.ttf'], 'base64'),
                italics: Buffer.from(VfsFonts.pdfMake.vfs['Roboto-Italic.ttf'], 'base64'),
                bolditalics: Buffer.from(VfsFonts.pdfMake.vfs['Roboto-MediumItalic.ttf'], 'base64')
            }
        };
        const printer = new PdfPrinter(fonts);
        const docContent = [];
        const filename = this._generateFilename(questionnaireEntries);

        docContent.push({
            'text': warningMsg,
            'style': 'h3',
            'margin': [ 0, 20, 0, 5 ]
        })
        docContent.push({
            toc: {
                title: {
                    text: `${questionnaireEntries.appId} Questionnaire`,
                    style: 'toc',
                    margin: [ 0, 40, 0, 20 ]
                },
                numberStyle: 'tocItem'
            }
        });

        

        this._questionnaireMetaStack = [];
        this._pushMetaToQuestionnaireMetaStack(questionnaireEntries);
        docContent.push({
            stack: this._questionnaireMetaStack
        });

        questionnaireEntries.entries.forEach(entry => {

            docContent.push({
                'text': `Section: ${entry.SECTION_ID}`,
                'style': 'h1',
                'tocItem': true,
                'tocStyle': 'tocItem',
                'tocMargin': [ 0, 4 ],
                'margin': [ 0, 15, 0, 5 ],
                'pageBreak' : 'before'
            });

            if (!entry.SUBSECTIONS.length) {
                // Section Questions
                entry.QUESTIONS.forEach(QUESTION => {
                    let questionStyle = 'question';

                    if (QUESTION.MANDATORY !== null && QUESTION.MANDATORY !== 0) {
                        questionStyle = this._getQuestionStyle(QUESTION)
                    }

                    this._questionStack = [];

                    this._questionStack.push({
                        'text': `Question: ${QUESTION.DESCR}?`,
                        'style': questionStyle,
                        'margin': [ 0, 20, 0, 5 ]
                    });

                    if (QUESTION.HELP_TEXT !== null) {
                        this._questionStack.push({
                            'text': `${QUESTION.HELP_TEXT}`,
                            'style': 'help',
                            'margin': [ 0, 5, 0, 5 ]
                        });
                    }

                    // Add current question stack
                    docContent.push({
                        stack: this._questionStack,
                        unbreakable: true
                    });

                    switch(this._getResponseType(QUESTION.QUESTION_TYPE_SID)) {
                        case EResponseType.SINGLE_CHOICE:
                            this._pushToStackSingleChoice(QUESTION.ANSWERS, QUESTION.RESPONSE_CHOICES);
                            break;
                        case EResponseType.MULTIPLE_CHOICE:
                            this._pushToStackMultipleChoice(QUESTION.ANSWERS, QUESTION.RESPONSE_CHOICES);
                            break;
                        case EResponseType.NO_CHOICE:
                            this._pushToStackNoChoice(QUESTION.ANSWERS);
                            break;
                        case EResponseType.LINKED_ENTRIES:
                            this._pushToStackLinkedEntries(QUESTION.LINKED_ENTRIES);
                            break;
                        case EResponseType.NUMERICAL_TARGET:
                            this._pushToStackNumericalTargets(QUESTION.TARGETS);
                            break;
                        case EResponseType.ASSESSMENT_COMPLIANCE:
                            this._pushToStackAsssessmentCompliance(QUESTION.COMPLIANCE);
                            break;
                        default:
                            this._pushToStackSingleValue(QUESTION.ANSWERS[0]);
                    }

                    if (QUESTION.ADD_INFO !== null) {
                        this._pushToStackAdditionalInfo(QUESTION.ADDITIONAL_INFO_TEXT[0])
                    }
                })

            } else {
                // Subsection Questions
                entry.SUBSECTIONS.forEach(SUBSECTION => {
                    docContent.push({
                        'text': `Subsection: ${SUBSECTION.SECTION_ID}`,
                        'style': 'h2',
                        'tocItem': true,
                        'tocStyle': 'tocItem',
                        'tocMargin': [ 10, 4, 0, 4 ],
                        'margin': [ 0, 30, 0, 5 ]
                    });
                    SUBSECTION.questions.forEach(QUESTION => {
                        let questionStyle = 'question';

                        if (QUESTION.MANDATORY !== null && QUESTION.MANDATORY !== 0) {
                            questionStyle = this._getQuestionStyle(QUESTION)
                        }

                        this._questionStack = [];

                        this._questionStack.push({
                            'text': `Question: ${QUESTION.DESCR}?`,
                            'style': questionStyle,
                            'margin': [ 0, 20, 0, 5 ]
                        });

                        if (QUESTION.HELP_TEXT !== null) {
                            this._questionStack.push({
                                'text': `${QUESTION.HELP_TEXT}`,
                                'style': 'help',
                                'margin': [ 0, 5, 0, 5 ]
                            });
                        }

                        // Add current question stack
                        docContent.push({
                            stack: this._questionStack,
                            unbreakable: true
                        });

                        switch(this._getResponseType(QUESTION.QUESTION_TYPE_SID)) {
                            case EResponseType.SINGLE_CHOICE:
                                this._pushToStackSingleChoice(QUESTION.ANSWERS, QUESTION.RESPONSE_CHOICES);
                                break;
                            case EResponseType.MULTIPLE_CHOICE:
                                this._pushToStackMultipleChoice(QUESTION.ANSWERS, QUESTION.RESPONSE_CHOICES);
                                break;
                            case EResponseType.NO_CHOICE:
                                this._pushToStackNoChoice(QUESTION.ANSWERS);
                                break;
                            case EResponseType.LINKED_ENTRIES:
                                this._pushToStackLinkedEntries(QUESTION.LINKED_ENTRIES);
                                break;
                            case EResponseType.NUMERICAL_TARGET:
                                this._pushToStackNumericalTargets(QUESTION.TARGETS);
                                break;
                            case EResponseType.ASSESSMENT_COMPLIANCE:
                                this._pushToStackAsssessmentCompliance(QUESTION.COMPLIANCE);
                                break;
                            default:
                                this._pushToStackSingleValue(QUESTION.ANSWERS[0]);
                        }

                        if (QUESTION.ADD_INFO !== null) {
                            this._pushToStackAdditionalInfo(QUESTION.ADDITIONAL_INFO_TEXT[0])
                        }
                    })
                })
            }

            // Add vertical gap for next section
            docContent.push({
                text: '',
                margin: [0, 20]
            });
        })

        const docDefinition = {
            content: docContent,
            margin: [ 72, 72, 72, 72 ],
            permissions: {
                modifying: true,
                copying: true,
                annotating: true,
                fillingForms: true,
                contentAccessibility: true,
                documentAssembly: true
            },
            footer: function (currentPage, pageCount) {
                return {
                    layout: 'noBorders',
                    table: {
                        widths: ["*"],
                        body: [
                            [
                                {text: 'Page ' + currentPage + ' of ' + pageCount, alignment: 'center'}
                            ]
                        ]
                    },
                };
            },
            defaultStyle: {
              font: 'Roboto',
              fontSize: 11
            },
            styles: {
                toc: {
                    fontSize: 30,
                    bold: true
                },
                tocItem: {
                    fontSize: 16
                },
                title: {
                    fontSize: 30,
                    bold: true
                },
                h1: {
                    fontSize: 22,
                    bold: true
                },
                h2: {
                    fontSize: 18,
                    bold: true
                },
                h3: {
                    fontSize: 14,
                    bold: true,
                    color: 'red'
                },
                meta: {
                    fontSize: 12
                },
                question: {
                    fontSize: 12,
                    color: 'dimgrey'
                },
                question_unanswered: {
                    fontSize: 12,
                    color: 'red'
                },
                help: {
                    fontSize: 10,
                    italics: true
                },
                answer: {
                    fontSize: 11
                },
                answer_none: {
                    fontSize: 11,
                    color: 'red'
                },
                provideDetails: {
                    fontSize: 10,
                    italics: true
                }
            }
        };

        res.setHeader("Content-Type", "application/pdf");
        res.setHeader("Content-Disposition", "attachment; filename=" + filename);

        const pdfDoc = printer.createPdfKitDocument(docDefinition);
        pdfDoc.pipe(res);
        pdfDoc.end();

        return await new Promise(resolve => res.on('finish', resolve));
    }

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Private Methods ////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    private _getEntryPrefix(appId: string): string {
        switch(appId) {
            case EFgdAppId.NFR:
                return 'Rule';
            case EFgdAppId.IFI:
                return 'Institution';
            case EFgdAppId.MTBF:
                return 'Framework';
            default:
                return '';
        }
    }

    private _generateFilename(questionnaireEntries: IQuestionnaireEntries): string {
        const todayFormatted =  String(this._today.getDate()).padStart(2, '0') +
                                String(this._today.getMonth() + 1).padStart(2, '0') +
                                this._today.getFullYear().toString().substr(-2);

        if (questionnaireEntries.appId === 'NFR' || questionnaireEntries.appId === 'MTBF') {
            return  questionnaireEntries.appId.toLowerCase() + '__questionnaire_' +
                    questionnaireEntries.countryCode.toLowerCase() + '_' +
                    questionnaireEntries.entryNo + '_' +
                    questionnaireEntries.entryVersion + '_' +
                    questionnaireEntries.year + '_' +
                    todayFormatted + '.pdf';
        } else {
            return  questionnaireEntries.appId.toLowerCase() + '__questionnaire_' +
                    questionnaireEntries.countryCode.toLowerCase() + '_' +
                    questionnaireEntries.year + '_' +
                    todayFormatted + '.pdf';
        }
    }

    private _getResponseType(questionTypeSid: number): string {
        let responseType: string;

        switch(questionTypeSid) {
            case EQuestionType.SINGLE_CHOICE:
            case EQuestionType.SINGLE_DROPDOWN:
            case EQuestionType.ASSESSMENT_SINGLE_CHOICE:
                responseType = EResponseType.SINGLE_CHOICE;
                break;
            case EQuestionType.MULTIPLE_CHOICE:
            case EQuestionType.MULTIPLE_DROPDOWN:
            case EQuestionType.ASSESSMENT_MULTIPLE_CHOICE:
            case EQuestionType.ASSESSMENT_MULTIPLE_TEXT:
                responseType = EResponseType.MULTIPLE_CHOICE;
                break;
            case EQuestionType.NUMERICAL_TARGET:
                responseType = EResponseType.NUMERICAL_TARGET;
                break;
            case EQuestionType.LINKED_ENTRIES:
                responseType = EResponseType.LINKED_ENTRIES;
                break;
            case EQuestionType.NO_CHOICE:
                responseType = EResponseType.NO_CHOICE;
                break;
            case EQuestionType.ASSESSMENT_COMPLIANCE:
                responseType = EResponseType.ASSESSMENT_COMPLIANCE;
                break;
            default:
                responseType = EResponseType.SINGLE_VALUE;
        }

        return responseType;
    }

    /* eslint-disable-next-line @typescript-eslint/no-explicit-any */
    private _getQuestionStyle(question: any): string {
        let questionStyle = 'question';

        if (question.MANDATORY !== null) {
            if (this._getResponseType(question.QUESTION_TYPE_SID) === EResponseType.SINGLE_VALUE) {
                if (!question.ANSWERS[0].length) {
                    questionStyle = 'question_unanswered';
                }
            } else {
                if (!question.ANSWERS.length) {
                    questionStyle = 'question_unanswered';
                }
            }
        }

        return questionStyle;
    }

    private _pushMetaToQuestionnaireMetaStack(questionnaireEntries: IQuestionnaireEntries): void {
        this._questionnaireMetaStack = [];

        this._questionnaireMetaStack.push({
            'text': '',
            'margin': [0, 40]
        });

        this._questionnaireMetaStack.push({
            'text': `Country: ${questionnaireEntries.countryCode}`,
            'style': 'meta',
            'tocStyle': 'tocItem',
            'tocMargin': [ 10, 4, 0, 4 ],
            'margin': [ 0, 5, 0, 5 ]
        });

        this._questionnaireMetaStack.push({
            'text': `Year: ${questionnaireEntries.year}`,
            'style': 'meta',
            'tocStyle': 'tocItem',
            'tocMargin': [ 10, 4, 0, 4 ],
            'margin': [ 0, 5, 0, 5 ]
        });

        if (questionnaireEntries.appId !== 'GBD') {
            const entryPrefix = this._getEntryPrefix(questionnaireEntries.appId)
            this._questionnaireMetaStack.push({
                'text': `${entryPrefix} No: ${questionnaireEntries.entryNo}`,
                'style': 'meta',
                'tocStyle': 'tocItem',
                'tocMargin': [ 10, 4, 0, 4 ],
                'margin': [ 0, 5, 0, 5 ]
            });

            this._questionnaireMetaStack.push({
                'text': `${entryPrefix} Version: ${questionnaireEntries.entryVersion}`,
                'style': 'meta',
                'tocStyle': 'tocItem',
                'tocMargin': [ 10, 4, 0, 4 ],
                'margin': [ 0, 5, 0, 5 ]
            });
        }

        const todayFormatted =  String(this._today.getDate()).padStart(2, '0') + '/' +
                                String(this._today.getMonth() + 1).padStart(2, '0') + '/' +
                                this._today.getFullYear();

        this._questionnaireMetaStack.push({
            'text': `Date Printed: ${todayFormatted}`,
            'style': 'meta',
            'tocStyle': 'tocItem',
            'tocMargin': [ 10, 4, 0, 4 ],
            'margin': [ 0, 5, 0, 5 ]
        });
    }

    private _pushToStackSingleValue(response: string): void {
        this._questionStack.push({
            'text': response,
            'style': 'answer',
            'margin': [ 0, 5, 0, 5 ]
        });
    }

    /* eslint-disable-next-line @typescript-eslint/no-explicit-any */
    private _pushToStackSingleChoice(answers: IPdfChoice[], responseChoices: any[]): void {
        responseChoices.forEach( choice => {
            let choiceSelected = false;
            let provideDetails = '';
            let choiceDescr = choice.descr;

            for (const answer of answers) {
                if (answer.sid === choice.sid) {
                    choiceSelected = true;
                    if (answer.provideDetails !== undefined) {
                        if (answer.provideDetails.length) {
                            provideDetails = answer.provideDetails[0].DESCR;
                        }
                    }
                    if (answer.needsDetails !== null && (answer.needsDetails === 2 || answer.needsDetails === 3)) {
                        choiceDescr = choiceDescr + ' - ' + answer.institution;
                    }
                    break;
                }
            }

            const radioState = choiceSelected ? this._radioSelected : this._radioUnSelected;

            this._questionStack.push({
                'columns': [
                    {
                        'image': radioState,
                        'width': 10,
                        'height': 10
                    },
                    {
                        'width': '*',
                        'text': choiceDescr
                    }
                ],
                'columnGap': 10,
                'style': 'answer',
                'margin': [ 0, 5, 0, 5 ]
            });

            if (choiceSelected && choice.needsDetails !== null && choice.needsDetails === 1 && provideDetails !== undefined) {
                this._pushToStackProvideDetails(provideDetails);
            }

        })
    }

    /* eslint-disable-next-line @typescript-eslint/no-explicit-any */
    private _pushToStackMultipleChoice(answers: IPdfChoice[], responseChoices: any[]): void {
        responseChoices.forEach( choice => {
            let choiceSelected = false;
            let provideDetails = '';
            let choiceDescr = choice.descr;

            for (const answer of answers) {
                if (answer.sid === choice.sid) {
                    choiceSelected = true;
                    if (answer.provideDetails !== undefined) {
                        if (answer.provideDetails.length) {
                            provideDetails = answer.provideDetails[0].DESCR;
                        }
                    }
                    if (answer.needsDetails !== null && (answer.needsDetails === 2 || answer.needsDetails === 3)) {
                        choiceDescr = choiceDescr + ' - ' + answer.institution;
                    }
                    break;
                }
            }

            const checkBoxState = choiceSelected ? this._checkboxChecked : this._checkboxUnChecked;

            this._questionStack.push({
                'columns': [
                    {
                        'image': checkBoxState,
                        'width': 10,
                        'height': 10
                    },
                    {
                        'width': '*',
                        'text': choiceDescr
                    }
                ],
                'columnGap': 10,
                'style': 'answer',
                'margin': [ 0, 5, 0, 5 ]
            });

            if (choiceSelected && choice.needsDetails !== null && choice.needsDetails === 1 && provideDetails !== undefined) {
                this._pushToStackProvideDetails(provideDetails);
            }

        })
    }

    private _pushToStackNoChoice(answers: IPdfChoice[]): void {
        answers.forEach( answer => {
            this._questionStack.push({
                'columns': [
                    {
                        'image': this._checkboxChecked,
                        'width': 10,
                        'height': 10
                    },
                    {
                        'width': 150,
                        'text': answer.descr
                    },
                    {
                        'width': '*',
                        'text': answer.provideDetails[0] !== undefined ? answer.provideDetails[0].NUMERIC_VALUE: ''
                    }
                ],
                'columnGap': 10,
                'style': 'answer',
                'margin': [ 0, 5, 0, 5 ]
            });
        })
    }

    private _pushToStackLinkedEntries(linkedEntries: IPdfLinkedEntry[]): void {
        linkedEntries.forEach( linkedEntry => {
            const linkedEntryDescr =    'Rule: ' +
                                        linkedEntry.linkedEntrySummary.nature +
                                        ' (' + linkedEntry.linkedEntrySummary.sectors + ')';
            this._questionStack.push({
                'columns': [
                    {
                        'image': this._radioUnSelected,
                        'width': 10,
                        'height': 10
                    },
                    {
                        'width': '*',
                        'text': linkedEntryDescr
                    }
                ],
                'columnGap': 10,
                'style': 'answer',
                'margin': [ 0, 5, 0, 5 ]
            });
        })
    }

    private _pushToStackNumericalTargets(targets: IPdfNumericalTarget[]): void {
        targets.forEach( target => {
            const targetValue =  target.NOT_APPLICABLE === null ? target.NUMERIC_VALUE : 'N/A';

            this._questionStack.push({
                'columns': [
                    {
                        'width': 50,
                        'text': target.RESPONSE_SID
                    },
                    {
                        'width':  '*',
                        'text': targetValue
                    }
                ],
                'columnGap': 10,
                'style': 'answer',
                'margin': [ 0, 5, 0, 5 ]
            });
        })
    }

    private _pushToStackAsssessmentCompliance(compliance: IPdfCompliance): void {
        this._questionStack.push({
            'columns': [
                {
                    'image': this._radioSelected,
                    'width': 10,
                    'height': 10
                },
                {
                    'width': '*',
                    'text': compliance.complianceSource
                },
                {
                    'width': '*',
                    'text': compliance.complianceValue
                }
            ],
            'columnGap': 10,
            'style': 'answer',
            'margin': [ 0, 5, 0, 5 ]
        });
    }

    private _pushToStackProvideDetails(provideDetails: string): void {
        const provideDetailsText = provideDetails !== undefined ? provideDetails: '';
        const answerStyle = provideDetails.length ? 'answer' : 'answer_none';

        this._questionStack.push({
            'text': 'Provide details: ' + provideDetailsText,
            'style': answerStyle,
            'margin': [ 20, 5, 0, 5 ]
        });
    }

    private _pushToStackAdditionalInfo(additionalInformation: string): void {
        const addInfoText = additionalInformation !== undefined ? additionalInformation: '';

        this._questionStack.push({
            'text': 'Additional Information: ' + addInfoText,
            'style': 'answer',
            'margin': [ 0, 5, 0, 5 ]
        });
    }
}