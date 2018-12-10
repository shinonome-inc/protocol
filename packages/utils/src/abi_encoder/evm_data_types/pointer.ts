import { DataItem } from 'ethereum-types';

import { DataType } from '../abstract_data_types/data_type';
import { DataTypeFactory } from '../abstract_data_types/interfaces';
import { AbstractPointerDataType } from '../abstract_data_types/types/pointer';

export class PointerDataType extends AbstractPointerDataType {
    constructor(destDataType: DataType, parentDataType: DataType, dataTypeFactory: DataTypeFactory) {
        const destDataItem = destDataType.getDataItem();
        const dataItem: DataItem = { name: `ptr<${destDataItem.name}>`, type: `ptr<${destDataItem.type}>` };
        super(dataItem, dataTypeFactory, destDataType, parentDataType);
    }

    public getSignature(): string {
        return this._destination.getSignature();
    }
}