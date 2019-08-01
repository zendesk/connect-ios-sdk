/*
 *  Copyright (c) 2019 Zendesk. All rights reserved.
 *
 *  By downloading or using the Zendesk Mobile SDK, You agree to the Zendesk Master
 *  Subscription Agreement https://www.zendesk.com/company/customers-partners/master-subscription-agreement and Application Developer and API License
 *  Agreement https://www.zendesk.com/company/customers-partners/application-developer-api-license-agreement and
 *  acknowledge that such terms govern Your use of and access to the Mobile SDK.
 *
 */

import Foundation

final class ImageOperation: Operation {

    private let imageResource: ImageResource

    init(imageResource: ImageResource) {
        self.imageResource = imageResource
        super.init()
    }

    override func main() {

        guard isCancelled == false else { return }

        guard let url = imageResource.remoteURL else { return }

        guard let imageData = try? Data(contentsOf: url) else { return }

        self.imageResource.localData = imageData
    }
}
